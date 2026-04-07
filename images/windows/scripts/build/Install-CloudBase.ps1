# Install CloudBase-Init

Write-Output "Downloading CloudBase-Init"

try {
  Write-Output "Downloading CloudBaseInit Software"
  Invoke-WebRequest -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi" -OutFile CloudbaseInitSetup_x64.msi


  Write-Output "Installing CloudBaseInit"
  $cloudbase = (Start-Process msiexec.exe -ArgumentList "/i", "CloudbaseInitSetup_x64.msi", "/qb-", "/norestart" -NoNewWindow -Wait -PassThru)
  if ($cloudbase.ExitCode -ne 0) {
    Write-Error "Error installing CloudBaseInit Software"
    exit 1
  }

} catch {
  Write-Error $_.Exception
  exit 1
}
