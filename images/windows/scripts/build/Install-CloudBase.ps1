# Install CloudBase-Init

$cloudbaseInitUrl = "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi"
$cloudbaseInitInstaller = "CloudbaseInitSetup_x64.msi"

Write-Output "Downloading CloudBaseInit Software"
Invoke-DownloadWithRetry -Url $cloudbaseInitUrl -Path $cloudbaseInitInstaller

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
