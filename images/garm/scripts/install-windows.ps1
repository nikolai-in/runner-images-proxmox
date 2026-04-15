$ErrorActionPreference = 'Stop'

$ActRunnerVersion = "0.2.10"
$GitHubRunnerVersion = "2.316.1"
$GarmAgentVersion = "v0.1.4"
$NssmVersion = "2.24-103-gdee49fc"

Write-Output "==> Pre-installing Gitea act_runner"
$ActRunnerDir = "C:\act_runner"
New-Item -ItemType Directory -Force -Path $ActRunnerDir | Out-Null
Invoke-WebRequest -Uri "https://gitea.com/gitea/act_runner/releases/download/v$ActRunnerVersion/act_runner-$ActRunnerVersion-windows-amd64.exe" -OutFile "$ActRunnerDir\act_runner.exe"

Write-Output "==> Pre-installing GitHub actions-runner"
$GhRunnerDir = "C:\actions-runner"
New-Item -ItemType Directory -Force -Path $GhRunnerDir | Out-Null
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$GitHubRunnerVersion/actions-runner-win-x64-$GitHubRunnerVersion.zip" -OutFile "C:\actions-runner.zip"
Expand-Archive -Path "C:\actions-runner.zip" -DestinationPath $GhRunnerDir -Force
Remove-Item "C:\actions-runner.zip" -Force

Write-Output "==> Pre-installing garm-agent"
$GarmAgentDir = "C:\garm-agent"
New-Item -ItemType Directory -Force -Path $GarmAgentDir | Out-Null
Invoke-WebRequest -Uri "https://github.com/cloudbase/garm-agent/releases/download/v0.1.0-beta1/garm-agent-windows-amd64-v0.1.0-beta1.exe" -OutFile "$GarmAgentDir\garm-agent.exe"

Write-Output "==> Pre-installing nssm"
$NssmDir = "C:\nssm-temp"
New-Item -ItemType Directory -Force -Path $NssmDir | Out-Null
Invoke-WebRequest -Uri "https://nssm.cc/ci/nssm-$NssmVersion.zip" -OutFile "C:\nssm.zip"
Expand-Archive -Path "C:\nssm.zip" -DestinationPath $NssmDir -Force
Move-Item "$NssmDir\nssm-$NssmVersion\win64\nssm.exe" -Destination "C:\Windows\System32\nssm.exe" -Force
Remove-Item $NssmDir -Recurse -Force
Remove-Item "C:\nssm.zip" -Force

Write-Output "==> Installation complete!"
