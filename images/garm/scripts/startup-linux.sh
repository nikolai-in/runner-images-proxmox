#!/usr/bin/env bash
set -euo pipefail

# GARM Linux Runner Startup Script
# Expected Environment Variables:
# - METADATA_URL
# - CALLBACK_URL
# - BEARER_TOKEN
# - REPO_URL
# - RUNNER_NAME
# - RUNNER_LABELS
# - FORGE_TYPE (github | gitea)
# - AGENT_MODE (true | false)
# - AGENT_URL (if AGENT_MODE=true)
# - AGENT_TOKEN (if AGENT_MODE=true)
# - AGENT_SHELL (if AGENT_MODE=true)

RUNNER_NAME="${RUNNER_NAME:-}"

if [[ "${CALLBACK_URL}" != */status ]]; then
    CALLBACK_URL="${CALLBACK_URL}/status"
fi

function send_status() {
    local status="$1"
    local message="$2"
    local payload="{\"status\": \"$status\", \"message\": \"$message\"}"
    curl -fsSL -X POST -d "$payload" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer ${BEARER_TOKEN}" \
        "${CALLBACK_URL}" || true
}

function fail() {
    send_status "failed" "$1"
    echo "ERROR: $1"
    exit 1
}

send_status "installing" "Starting runner configuration..."

# 1. Fetch Runner Registration Token
RUNNER_TOKEN=$(curl -fsSL \
    -H "Authorization: Bearer ${BEARER_TOKEN}" \
    "${METADATA_URL}/runner-registration-token" | tr -d '"')

if [ -z "$RUNNER_TOKEN" ]; then
    fail "Failed to retrieve runner registration token"
fi

# 2. Configure Runner based on Forge Type
if [ "${FORGE_TYPE:-github}" = "gitea" ]; then
    RUNNER_HOME="/home/runner/act_runner"
    cd "$RUNNER_HOME"

    su -s /bin/bash runner -c "./act_runner generate-config > config.yaml"
    su -s /bin/bash runner -c "./act_runner register \
        --config config.yaml \
        --instance '${REPO_URL}' \
        --token '${RUNNER_TOKEN}' \
        --name '${RUNNER_NAME}' \
        --labels '${RUNNER_LABELS}' \
        --no-interactive" || fail "Failed to register act_runner"

    sed -i 's/act_runner daemon/act_runner daemon --config config.yaml/' /etc/systemd/system/act_runner.service || true
    systemctl daemon-reload
    systemctl enable --now act_runner
else
    RUNNER_HOME="/home/runner/actions-runner"
    cd "$RUNNER_HOME"

    su -s /bin/bash runner -c "./config.sh \
        --url '${REPO_URL}' \
        --token '${RUNNER_TOKEN}' \
        --name '${RUNNER_NAME}' \
        --labels '${RUNNER_LABELS}' \
        --unattended \
        --replace \
        --ephemeral" || fail "Failed to register GitHub runner"

    ./svc.sh install runner
    ./svc.sh start
fi

# 3. Configure Agent Mode (if applicable)
if [ "${AGENT_MODE:-false}" = "true" ]; then
    send_status "installing" "Configuring GARM agent..."
    cat > /etc/garm-agent/garm-agent.toml << EOF
server_url = "${AGENT_URL}"
log_file = "/var/log/garm-agent/garm-agent.log"
work_dir = "${RUNNER_HOME}"
enable_shell = ${AGENT_SHELL:-false}
token = "${AGENT_TOKEN}"
runner_cmdline = ["${RUNNER_HOME}/act_runner", "daemon", "--once"]
state_db_path = "/etc/garm-agent/agent-state.db"
EOF
    systemctl enable --now garm-agent || fail "Failed to start garm-agent"
fi

# 4. Notify Success
# Attempt to get system info (simplified)
# shellcheck disable=SC1091
OS_NAME=$(source /etc/os-release && echo "$NAME")
# shellcheck disable=SC1091
OS_VERSION=$(source /etc/os-release && echo "$VERSION_ID")
AGENT_ID=$(grep '"id"' "${RUNNER_HOME}/.runner" 2>/dev/null | tr -d -c 0-9 || echo "null")

if [ "$AGENT_ID" != "null" ]; then
    SYSINFO_URL="${CALLBACK_URL%/status}/system-info/"
    SYSINFO_PAYLOAD="{\"os_name\": \"$OS_NAME\", \"os_version\": \"$OS_VERSION\", \"agent_id\": $AGENT_ID}"
    curl -fsSL -X POST -d "$SYSINFO_PAYLOAD" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer ${BEARER_TOKEN}" \
        "${SYSINFO_URL}" || true
fi

send_status "idle" "Runner successfully configured and started"
