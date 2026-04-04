################################################################################
##  File:  Configure-Powershell.ps1
##  Desc:  Manage PowerShell configuration
################################################################################

# Enable TLS 1.2 for this process before contacting any internet endpoints.
# This is required because the inbox PowerShellGet 1.x defaults to TLS 1.0.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#region System
Write-Host "Setup PowerShellGet"

# Retry wrapper: PSGallery / NuGet endpoints can be transiently unavailable.
function Invoke-WithRetry {
    param(
        [scriptblock] $Action,
        [string]      $Description = "operation",
        [int]         $MaxAttempts = 5,
        [int]         $DelaySeconds = 30
    )
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            & $Action
            return
        } catch {
            if ($attempt -eq $MaxAttempts) {
                Write-Host "ERROR: $Description failed after $MaxAttempts attempts: $_"
                throw
            }
            Write-Host "WARNING: $Description failed (attempt $attempt/$MaxAttempts): $_"
            Write-Host "Retrying in ${DelaySeconds}s..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

Invoke-WithRetry -Description "Install NuGet provider" -Action {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

# Trust PSGallery so that Install-Module works without prompts.
# PSGallery can be transiently unreachable, and the NuGet provider bootstrap can
# unregister it when that happens.  Retry and re-register as needed.
Invoke-WithRetry -Description "Trust PSGallery" -Action {
    if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
        Write-Host "PSGallery not registered, re-registering with Register-PSRepository -Default..."
        Register-PSRepository -Default -ErrorAction Stop
    }
    Set-PSRepository -InstallationPolicy Trusted -Name PSGallery -ErrorAction Stop
}

Write-Host 'Warmup PSModuleAnalysisCachePath (speedup first powershell invocation by 20s)'
$PSModuleAnalysisCachePath = 'C:\PSModuleAnalysisCachePath\ModuleAnalysisCache'

[Environment]::SetEnvironmentVariable('PSModuleAnalysisCachePath', $PSModuleAnalysisCachePath, "Machine")
# make variable to be available in the current session
${env:PSModuleAnalysisCachePath} = $PSModuleAnalysisCachePath

New-Item -Path $PSModuleAnalysisCachePath -ItemType 'File' -Force | Out-Null
#endregion

#region User (current user, image generation only)
if (-not (Test-Path $profile)) {
    New-Item $profile -ItemType File -Force
}

# PowerHTML is installed as an AllUsers module by Install-PowerShellModules.ps1.
# The profile only needs to import it for the current session.
@"
  if ( -not(Get-Module -Name PowerHTML)) {
      Import-Module PowerHTML -ErrorAction SilentlyContinue
  }
"@ | Add-Content -Path $profile -Force

#endregion
