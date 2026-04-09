################################################################################
##  File:  Copy-ImageFilesFromISO.ps1
##  Desc:  Copy assets, scripts, toolsets and software-report-base from the
##         ImageFiles virtual CD-ROM (mounted by the proxmox-clone Packer source
##         via additional_iso_files) to the image folder.  Using an ISO avoids
##         slow WinRM file transfer for large directory trees.
##
##         This script is intentionally run for ALL Packer sources (no 'only'
##         filter in the provisioner block).  When the ImageFiles CD-ROM is not
##         present (e.g. null.winrm debug builds where WinRM file provisioners
##         have already delivered the files) it prints a warning and exits
##         cleanly so the build is not interrupted.
################################################################################

$ErrorActionPreference = 'Stop'

Write-Host "Copy-ImageFilesFromISO: starting (IMAGE_FOLDER=$env:IMAGE_FOLDER)"

if ([string]::IsNullOrWhiteSpace($env:IMAGE_FOLDER)) {
    throw "IMAGE_FOLDER environment variable is not set"
}

if (-not (Test-Path -LiteralPath $env:IMAGE_FOLDER -PathType Container)) {
    throw "IMAGE_FOLDER path does not exist or is not a directory: $env:IMAGE_FOLDER"
}

$vol = Get-Volume -FileSystemLabel 'ImageFiles' -ErrorAction SilentlyContinue
if (-not $vol) {
    Write-Warning "ImageFiles CD-ROM not found - skipping ISO copy (expected on null.winrm debug builds)"
    return
}

$drive = $vol.DriveLetter + ':'
Write-Host "Copy-ImageFilesFromISO: ImageFiles volume found on drive $drive"

Write-Host "Copy-ImageFilesFromISO: copying assets..."
Copy-Item -Path "$drive\assets"   -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop
Write-Host "Copy-ImageFilesFromISO: copying scripts..."
Copy-Item -Path "$drive\scripts"  -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop
Write-Host "Copy-ImageFilesFromISO: copying toolsets..."
Copy-Item -Path "$drive\toolsets" -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop

Write-Host "Copy-ImageFilesFromISO: copying software-report-base into scripts\docs-gen..."
New-Item -ItemType Directory -Path "$env:IMAGE_FOLDER\scripts\docs-gen" -Force | Out-Null
Copy-Item -Path "$drive\software-report-base" -Destination "$env:IMAGE_FOLDER\scripts\docs-gen\" -Recurse -Force -ErrorAction Stop

Write-Host "Copy-ImageFilesFromISO: done"
