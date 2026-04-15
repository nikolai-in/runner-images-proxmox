$ErrorActionPreference = 'Stop'

# Read environment variables injected by cloudbase-init / provider
$MetadataUrl = $env:METADATA_URL
$CallbackUrl = $env:CALLBACK_URL
$BearerToken = $env:BEARER_TOKEN
$RepoUrl = $env:REPO_URL
$RunnerName = $env:RUNNER_NAME
$RunnerLabels = $env:RUNNER_LABELS
$ForgeType = $env:FORGE_TYPE
$AgentMode = $env:AGENT_MODE
$AgentUrl = $env:AGENT_URL
$AgentToken = $env:AGENT_TOKEN
$AgentShell = $env:AGENT_SHELL

if (-not $CallbackUrl.EndsWith("/status")) {
    $CallbackUrl = "$CallbackUrl/status"
}

function Send-Status {
    param([string]$Status, [string]$Message)
    $Payload = @{ status = $Status; message = $Message } | ConvertTo-Json -Depth 2 -Compress
    try {
        Invoke-RestMethod -Uri $CallbackUrl -Method Post -Body $Payload `
            -Headers @{ 'Accept' = 'application/json'; 'Authorization' = "Bearer $BearerToken" } `
            -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
    } catch { Write-Verbose $_ }
}

function Fail {
    param([string]$Message)
    Send-Status -Status "failed" -Message $Message
    Write-Error "ERROR: $Message"
    exit 1
}

Send-Status -Status "installing" -Message "Starting runner configuration..."

# 1. Fetch Runner Registration Token
try {
    $RunnerToken = (Invoke-RestMethod -Uri "$MetadataUrl/runner-registration-token" `
        -Headers @{ 'Authorization' = "Bearer $BearerToken" }).Trim('"')
} catch {
    Fail "Failed to retrieve runner registration token: $_"
}

if ([string]::IsNullOrEmpty($RunnerToken)) {
    Fail "Runner registration token is empty"
}

# 2. Configure Runner based on Forge Type
if ($ForgeType -eq "gitea") {
    $RunnerHome = "C:\act_runner"
    Set-Location $RunnerHome

    try {
        & .\act_runner.exe generate-config | Out-File -Encoding utf8 config.yaml
        & .\act_runner.exe register --config config.yaml --instance $RepoUrl --token $RunnerToken --name $RunnerName --labels $RunnerLabels --no-interactive
        if ($LASTEXITCODE -ne 0) { Fail "Failed to register act_runner" }

        nssm install act_runner "$RunnerHome\act_runner.exe"
        nssm set act_runner AppParameters "daemon --config $RunnerHome\config.yaml"
        nssm set act_runner AppDirectory $RunnerHome
        nssm set act_runner AppStdout "$RunnerHome\stdout.log"
        nssm set act_runner AppStderr "$RunnerHome\stderr.log"
        Start-Service act_runner
    } catch {
        Fail "Failed to configure Gitea runner: $_"
    }
} else {
    $RunnerHome = "C:\actions-runner"
    Set-Location $RunnerHome

    try {
        & .\config.cmd --url $RepoUrl --token $RunnerToken --name $RunnerName --labels $RunnerLabels --unattended --replace --ephemeral
        if ($LASTEXITCODE -ne 0) { Fail "Failed to register GitHub runner" }

        & .\svc.cmd install
        & .\svc.cmd start
    } catch {
        Fail "Failed to configure GitHub runner: $_"
    }
}

# 3. Configure Agent Mode
if ($AgentMode -eq "true") {
    Send-Status -Status "installing" -Message "Configuring GARM agent..."
    $AgentDir = "C:\garm-agent"
    $EnableShell = if ($AgentShell -eq "true") { "true" } else { "false" }

    $AgentConfig = @"
server_url = "$AgentUrl"
log_file = "$AgentDir\garm-agent.log"
work_dir = "$RunnerHome"
enable_shell = $EnableShell
token = "$AgentToken"
runner_cmdline = ["$RunnerHome\act_runner.exe", "daemon", "--once"]
state_db_path = "$AgentDir\agent-state.db"
"@
    Set-Content -Path "$AgentDir\garm-agent.toml" -Value $AgentConfig -Encoding UTF8

    try {
        nssm install garm-agent "$AgentDir\garm-agent.exe"
        nssm set garm-agent AppParameters "daemon --config $AgentDir\garm-agent.toml"
        nssm set garm-agent AppDirectory $AgentDir
        nssm set garm-agent AppStdout "$AgentDir\stdout.log"
        nssm set garm-agent AppStderr "$AgentDir\stderr.log"
        Start-Service garm-agent
    } catch {
        Fail "Failed to start garm-agent: $_"
    }
}

# 4. Notify Success
try {
    $OsInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $OsName = $OsInfo.Caption
    $OsVersion = $OsInfo.Version

    $AgentId = "null"
    $RunnerFile = Join-Path $RunnerHome ".runner"
    if (Test-Path $RunnerFile) {
        $RunnerData = Get-Content $RunnerFile | ConvertFrom-Json
        if ($null -ne $RunnerData.id) {
            $AgentId = $RunnerData.id
        }
    }

    $SysInfoUrl = $CallbackUrl.Replace("/status", "/system-info/")
    $SysInfoPayload = @{
        os_name = $OsName
        os_version = $OsVersion
        agent_id = $AgentId
    } | ConvertTo-Json -Depth 2 -Compress

    Invoke-RestMethod -Uri $SysInfoUrl -Method Post -Body $SysInfoPayload `
        -Headers @{ 'Accept' = 'application/json'; 'Authorization' = "Bearer $BearerToken" } `
        -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
} catch { Write-Verbose $_ }

Send-Status -Status "idle" -Message "Runner successfully configured and started"
