################################################################################
##  File:  Install-Runner.ps1
##  Desc:  Install GitHub Actions Runner and Gitea Act Runner
##  Supply chain security: none
################################################################################

Write-Output "Download latest Runner for GitHub Actions"
$downloadUrl = Resolve-GithubReleaseAssetUrl `
    -Repo "actions/runner" `
    -Version "latest" `
    -UrlMatchPattern "actions-runner-win-x64-*[0-9.].zip"
$fileName = Split-Path $downloadUrl -Leaf
New-Item -Path "C:\ProgramData\runner" -ItemType Directory
Invoke-DownloadWithRetry -Url $downloadUrl -Path "C:\ProgramData\runner\$fileName"

Write-Output "Download latest Gitea Act Runner"
$giteaApiUrl = "https://gitea.com/api/v1/repos/gitea/act_runner/releases?limit=1"
$latestRelease = Invoke-RestMethod -Uri $giteaApiUrl | Select-Object -First 1
$actRunnerAsset = $latestRelease.assets | Where-Object { $_.name -like "act_runner-*-windows-amd64.exe" } | Select-Object -First 1
if (-not $actRunnerAsset) {
    throw "Could not find act_runner Windows AMD64 asset in latest release $($latestRelease.tag_name)"
}
$actRunnerDir = "C:\ProgramData\act_runner"
New-Item -Path $actRunnerDir -ItemType Directory -Force
Invoke-DownloadWithRetry -Url $actRunnerAsset.browser_download_url -Path "$actRunnerDir\act_runner.exe"
Write-Output "Gitea Act Runner $($latestRelease.tag_name) installed to $actRunnerDir\act_runner.exe"

Invoke-PesterTests -TestFile "RunnerCache"
