#!/bin/bash
set -euo pipefail

ACT_RUNNER_DIR=/home/runner/act_runner
mkdir -p "$ACT_RUNNER_DIR"
cd "$ACT_RUNNER_DIR"

LATEST_RELEASE_URL=$(curl -fsSL "https://gitea.com/api/v1/repos/gitea/act_runner/releases?limit=1" | jq -r ".[0].assets[] | select(.name | test(\"act_runner-.*-linux-amd64$\")) | .browser_download_url" | head -1)

curl -fsSL "$LATEST_RELEASE_URL" -o act_runner
chmod +x act_runner

cat << "SERVICE" > /etc/systemd/system/act_runner.service
[Unit]
Description=Gitea Actions Runner
After=network.target

[Service]
ExecStart=/home/runner/act_runner/act_runner daemon
WorkingDirectory=/home/runner/act_runner
User=runner
Group=runner
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
SERVICE

systemctl enable act_runner
chmod -R 777 /home/runner
