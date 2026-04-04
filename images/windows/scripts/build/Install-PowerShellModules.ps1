################################################################################
##  File:  Install-PowershellModules.ps1
##  Desc:  Install common PowerShell modules
################################################################################

# Set TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# Retry wrapper: PSGallery can be transiently unavailable during image builds.
function Install-ModuleWithRetry {
    param(
        [string] $Name,
        [string] $RequiredVersion,
        [int]    $MaxAttempts = 5,
        [int]    $DelaySeconds = 60
    )
    $installParams = @{
        Name              = $Name
        Scope             = "AllUsers"
        SkipPublisherCheck = $true
        Force             = $true
    }
    if ($RequiredVersion) {
        $installParams.RequiredVersion = $RequiredVersion
    }

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            Install-Module @installParams
            return
        } catch {
            if ($attempt -eq $MaxAttempts) {
                Write-Host "ERROR: Failed to install module '$Name' after $MaxAttempts attempts: $_"
                throw
            }
            Write-Host "WARNING: Failed to install module '$Name' (attempt $attempt/$MaxAttempts): $_"
            Write-Host "Retrying in ${DelaySeconds}s..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

# Install PowerShell modules
$modules = (Get-ToolsetContent).powershellModules

foreach ($module in $modules) {
    $moduleName = $module.name
    Write-Host "Installing ${moduleName} module"

    if ($module.versions) {
        foreach ($version in $module.versions) {
            Write-Host " - $version"
            Install-ModuleWithRetry -Name $moduleName -RequiredVersion $version
        }
    } else {
        Install-ModuleWithRetry -Name $moduleName
    }
}

Import-Module Pester
Invoke-PesterTests -TestFile "PowerShellModules" -TestName "PowerShellModules"
