################################################################################
##  File:  Initialize-TempDisk.ps1
##  Desc:  Initialize, partition, and format the secondary raw disk added by
##         the Proxmox clone source as the D: (temp) drive.
##         Must run before any provisioner step that creates paths on D:.
################################################################################

Write-Host "Initializing secondary disk as D: drive"

$rawDisk = Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Select-Object -First 1

if ($null -eq $rawDisk) {
    Write-Host "No uninitialized (RAW) disk found - D: drive may already be configured"
    exit 0
}

Write-Host "  Found RAW disk: Disk $($rawDisk.Number) ($([math]::Round($rawDisk.Size / 1GB, 0)) GB)"

$rawDisk |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -DriveLetter D -UseMaximumSize |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "Temp" -Confirm:$false | Out-Null

Write-Host "D: drive initialized and formatted successfully"
