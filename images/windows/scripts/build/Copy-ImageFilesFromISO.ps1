################################################################################
##  File:  Copy-ImageFilesFromISO.ps1
##  Desc:  Copy assets, scripts, toolsets and software-report-base from the
##         ImageFiles virtual CD-ROM (mounted by the proxmox-clone Packer source
##         via additional_iso_files) to the image folder.  Using an ISO avoids
##         slow WinRM file transfer for large directory trees.
################################################################################

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:IMAGE_FOLDER)) {
    throw "IMAGE_FOLDER environment variable is not set"
}

if (-not (Test-Path -LiteralPath $env:IMAGE_FOLDER -PathType Container)) {
    throw "IMAGE_FOLDER path does not exist or is not a directory: $env:IMAGE_FOLDER"
}

$vol = Get-Volume -FileSystemLabel 'ImageFiles' -ErrorAction SilentlyContinue
if (-not $vol) {
    throw "ImageFiles CD-ROM not found - ensure the proxmox-clone source has additional_iso_files configured"
}
$drive = $vol.DriveLetter + ':'

Copy-Item -Path "$drive\assets"   -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop
Copy-Item -Path "$drive\scripts"  -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop
Copy-Item -Path "$drive\toolsets" -Destination "$env:IMAGE_FOLDER\" -Recurse -Force -ErrorAction Stop

New-Item -ItemType Directory -Path "$env:IMAGE_FOLDER\scripts\docs-gen" -Force | Out-Null
Copy-Item -Path "$drive\software-report-base\*" -Destination "$env:IMAGE_FOLDER\scripts\docs-gen\" -Recurse -Force -ErrorAction Stop
