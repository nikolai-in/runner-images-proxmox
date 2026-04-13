################################################################################
##  File:  Install-Runner.ps1
##  Desc:  Download and cache GitHub Actions Runner and Gitea Act Runner binaries
##  Supply chain security: GitHub Actions Runner - checksum validation; Gitea Act Runner - checksum validation
################################################################################

Write-Output "Download latest Runner for GitHub Actions"
$downloadUrl = Resolve-GithubReleaseAssetUrl `
    -Repo "actions/runner" `
    -Version "latest" `
    -UrlMatchPattern "actions-runner-win-x64-*[0-9.].zip"
$fileName = Split-Path $downloadUrl -Leaf



New-Item -Path "C:\ProgramData\runner" -ItemType Directory -Force | Out-Null
$runnerPath = Invoke-DownloadWithRetry -Url $downloadUrl -Path "C:\ProgramData\runner\$fileName"


Write-Output "Download latest Gitea Act Runner"
$giteaApiUrl = "https://gitea.com/api/v1/repos/gitea/act_runner/releases?limit=1"
$maxRetries = 3
$retryDelay = 5
$latestRelease = $null
for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
        $latestRelease = Invoke-RestMethod -Uri $giteaApiUrl | Select-Object -First 1
        break
    } catch {
        if ($attempt -eq $maxRetries) {
            throw "Failed to fetch Gitea act_runner releases after $maxRetries attempts: $_"
        }
        Write-Warning "Attempt $attempt failed fetching Gitea releases: $_. Retrying in ${retryDelay}s..."
        Start-Sleep -Seconds $retryDelay
    }
}
$actRunnerAsset = $latestRelease.assets | Where-Object { $_.name -like "act_runner-*-windows-amd64.exe" } | Select-Object -First 1
if (-not $actRunnerAsset) {
    throw "Could not find act_runner Windows AMD64 asset in latest release $($latestRelease.tag_name)"
}

$actRunnerDir = "C:\act_runner"
New-Item -Path $actRunnerDir -ItemType Directory -Force | Out-Null
$actRunnerPath = Invoke-DownloadWithRetry -Url "https://dl.gitea.com/act_runner/$($latestRelease.tag_name.TrimStart("v"))/act_runner-$($latestRelease.tag_name)-windows-amd64.exe" -Path "$actRunnerDir\act_runner.exe"

Write-Output "Gitea Act Runner $($latestRelease.tag_name) cached to $actRunnerPath"

if (-not (Get-Command nssm -ErrorAction SilentlyContinue)) {
    Write-Output "Installing NSSM"
    choco install nssm -y --no-progress
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Write-Output "Configuring Gitea Act Runner service via NSSM"
nssm install act_runner "$actRunnerPath" daemon
nssm set act_runner AppDirectory "$actRunnerDir"
nssm set act_runner DisplayName "Gitea Act Runner"
nssm set act_runner Description "Gitea Act Runner Service"
nssm set act_runner Start SERVICE_AUTO_START

Invoke-PesterTests -TestFile "RunnerCache"
