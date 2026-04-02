################################################################################
##  File:  Install-BaseWindowsUpdates.ps1
##  Desc:  Install critical Windows Updates for base image.
##         Uses PSWindowsUpdate module for reliable update management.
################################################################################

function Install-BaseWindowsUpdates {
    Write-Host "Starting Windows Update service"
    Start-Service -Name wuauserv -PassThru | Out-Host
    
    # Install PSWindowsUpdate module
    Write-Host "Installing PSWindowsUpdate module"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
    Import-Module PSWindowsUpdate -Force
    
    Write-Host "Searching for available Windows updates"
    
    # Get critical/important updates, excluding problematic ones
    $updates = Get-WindowsUpdate -MicrosoftUpdate -NotKBArticleID @("KB5034439") | Where-Object {
        $_.AutoSelectOnWebSites -eq $true -and
        $_.Title -notmatch "Preview|Beta|Windows Recovery Environment" -and
        $_.Title -notmatch "Microsoft Defender Antivirus" -and
        -not $_.BrowseOnly
    }
    
    if (-not $updates) {
        Write-Host "No critical/important Windows updates available to install"
        return
    }
    
    Write-Host "Found $($updates.Count) critical/important updates to install:"
    $updates | ForEach-Object { Write-Host "- $($_.Title)" }
    
    # Install updates
    Write-Host "Installing Windows updates..."
    try {
        Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot -MicrosoftUpdate -NotKBArticleID @("KB5034439") | Out-Host
        Write-Host "Windows updates installation completed"
    } catch {
        Write-Warning "Some updates may have failed: $($_.Exception.Message)"
        Write-Host "Continuing with image build"
    }
}

Install-BaseWindowsUpdates

# Create marker file to indicate base updates are complete
Write-Host "Creating base Windows update completion marker"
New-Item -Path $env:windir -Name BaseWindowsUpdateDone.txt -ItemType File -Force | Out-Null
