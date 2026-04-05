################################################################################
##  File:  Expand-RunnerDisk.ps1
##  Desc:  Extend the C: partition to fill the full disk size after the
##         packer-plugin-proxmox has configured scsi0 at the target size.
##         Run this as the first in-guest provisioner step in the runner build.
################################################################################

Write-Host "Expanding C: drive partition to fill available disk space"

$driveLetter   = "C"
$partition     = Get-Partition -DriveLetter $driveLetter
$diskNumber    = $partition.DiskNumber
$partNumber    = $partition.PartitionNumber
$supportedSize = Get-PartitionSupportedSize -DiskNumber $diskNumber -PartitionNumber $partNumber

$currentGB = [math]::Round($partition.Size / 1GB, 2)
$maxGB     = [math]::Round($supportedSize.SizeMax / 1GB, 2)

Write-Host "  Current size : ${currentGB} GB"
Write-Host "  Max available: ${maxGB} GB"

if ($partition.Size -lt $supportedSize.SizeMax) {
    Resize-Partition -DiskNumber $diskNumber -PartitionNumber $partNumber -Size $supportedSize.SizeMax
    Write-Host "C: drive successfully expanded to ${maxGB} GB"
} else {
    Write-Host "C: drive is already at maximum size — no resize needed"
}
