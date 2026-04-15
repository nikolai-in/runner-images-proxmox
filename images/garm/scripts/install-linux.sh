#!/usr/bin/env bash
set -euo pipefail

# This script is run by Packer to pre-install runner binaries and agents.
# It expects the following environment variables (or uses defaults):
ACT_RUNNER_VERSION=${ACT_RUNNER_VERSION:-"0.2.10"}
GITHUB_RUNNER_VERSION=${GITHUB_RUNNER_VERSION:-"2.316.1"}
GARM_AGENT_VERSION=${GARM_AGENT_VERSION:-"v0.1.4"}
TARGET_ARCH=${TARGET_ARCH:-"amd64"} # amd64 or arm64

echo "==> Creating runner user"
if ! id -u runner >/dev/null 2>&1; then
    useradd -m -s /bin/bash runner
    usermod -aG sudo runner
    echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner
fi

echo "==> Pre-installing Gitea act_runner"
ACT_RUNNER_DIR="/home/runner/act_runner"
mkdir -p "$ACT_RUNNER_DIR"
curl -fsSL -o "$ACT_RUNNER_DIR/act_runner" \
    "https://gitea.com/gitea/act_runner/releases/download/v${ACT_RUNNER_VERSION}/act_runner-v${ACT_RUNNER_VERSION}-linux-${TARGET_ARCH}"
chmod +x "$ACT_RUNNER_DIR/act_runner"
chown -R runner:runner "$ACT_RUNNER_DIR"

echo "==> Pre-installing GitHub actions-runner"
GH_RUNNER_DIR="/home/runner/actions-runner"
mkdir -p "$GH_RUNNER_DIR"
curl -fsSL -o /tmp/actions-runner.tar.gz \
    "https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz"
tar xzf /tmp/actions-runner.tar.gz -C "$GH_RUNNER_DIR"
rm /tmp/actions-runner.tar.gz
# GitHub runner requires some dependencies (if not already in the image)
if [ -f "$GH_RUNNER_DIR/bin/installdependencies.sh" ]; then
    sudo "$GH_RUNNER_DIR/bin/installdependencies.sh" || true
fi
chown -R runner:runner "$GH_RUNNER_DIR"

echo "==> Pre-installing garm-agent"
curl -fsSL -o /usr/local/bin/garm-agent \
    "https://github.com/cloudbase/garm/releases/download/${GARM_AGENT_VERSION}/garm-agent-linux-${TARGET_ARCH}"
chmod +x /usr/local/bin/garm-agent

echo "==> Preparing garm-agent systemd structure"
mkdir -p /var/log/garm-agent
chown runner:runner /var/log/garm-agent
mkdir -p /etc/garm-agent
chown runner:runner /etc/garm-agent

# Pre-create the garm-agent service (disabled by default)
cat > /etc/systemd/system/garm-agent.service << EOF
[Unit]
Description=GARM agent
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/garm-agent daemon --config /etc/garm-agent/garm-agent.toml
Restart=always
RestartSec=5s
User=runner
Environment=TERM=xterm-256color
Environment=LANG=en_US.UTF-8

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

echo "==> Installation complete!"
