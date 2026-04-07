# Install CloudBase-Init
# Note: This script runs in the base image build context where the ImageHelpers
# module is not available, so downloads are performed directly with Invoke-WebRequest.

$cloudbaseInitUrl = "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi"
$cloudbaseInitInstaller = "CloudbaseInitSetup_x64.msi"

Write-Output "Downloading CloudBaseInit Software"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $cloudbaseInitUrl -OutFile $cloudbaseInitInstaller -UseBasicParsing

$signature = Get-AuthenticodeSignature -FilePath $cloudbaseInitInstaller
if ($signature.Status -ne "Valid") {
    throw "CloudBaseInit installer signature validation failed. Status: $($signature.Status)"
}

Write-Output "Installing CloudBaseInit"
$cloudbase = (Start-Process msiexec.exe -ArgumentList "/i", $cloudbaseInitInstaller, "/qb-", "/norestart" -NoNewWindow -Wait -PassThru)
if ($cloudbase.ExitCode -ne 0) {
    Write-Error "Error installing CloudBaseInit Software"
    exit 1
}
