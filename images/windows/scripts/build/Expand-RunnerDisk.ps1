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
$disk          = Get-Disk -Number $diskNumber
$partNumber    = $partition.PartitionNumber

$currentGB = [math]::Round($partition.Size / 1GB, 2)
$diskGB    = [math]::Round($disk.Size / 1GB, 2)

Write-Host "  Current size : ${currentGB} GB"
Write-Host "  Total disk   : ${diskGB} GB"

# Check all partitions on this disk to see the layout
Write-Host "`nInitial disk layout on Disk $diskNumber :"
Get-Partition -DiskNumber $diskNumber | ForEach-Object {
    $type = if ($_.Type -eq "System") { "EFI/Recovery" } else { $_.Type }
    $sizeGB = [math]::Round($_.Size / 1GB, 2)
    Write-Host "  Partition $($_.PartitionNumber): $type - ${sizeGB} GB"
}

# Remove Recovery partitions if they exist
$recoveryPartitions = Get-Partition -DiskNumber $diskNumber | Where-Object {$_.Type -eq "Recovery"}
if ($recoveryPartitions) {
    Write-Host "`nRemoving Recovery partition(s) to allow expansion..."
    foreach ($recPartition in $recoveryPartitions) {
        try {
            Remove-Partition -DiskNumber $diskNumber -PartitionNumber $recPartition.PartitionNumber -Confirm:$false -ErrorAction Stop
            $recSizeGB = [math]::Round($recPartition.Size / 1GB, 2)
            Write-Host "  Removed Recovery partition $($recPartition.PartitionNumber) (${recSizeGB} GB)"
        } catch {
            Write-Host "  ERROR: Failed to remove Recovery partition: $_" -ForegroundColor Red
            exit 1
        }
    }
}

# Now get the updated supported size
$supportedSize = Get-PartitionSupportedSize -DiskNumber $diskNumber -PartitionNumber $partNumber
$maxGB     = [math]::Round($supportedSize.SizeMax / 1GB, 2)

Write-Host "`nFinal disk layout on Disk $diskNumber :"
Get-Partition -DiskNumber $diskNumber | ForEach-Object {
    $type = if ($_.Type -eq "System") { "EFI/Boot" } else { $_.Type }
    $sizeGB = [math]::Round($_.Size / 1GB, 2)
    Write-Host "  Partition $($_.PartitionNumber): $type - ${sizeGB} GB"
}

Write-Host "`nMax available for C: drive expansion: ${maxGB} GB"

if ($partition.Size -lt $supportedSize.SizeMax) {
    Write-Host "Resizing C: drive from ${currentGB} GB to ${maxGB} GB..."
    try {
        Resize-Partition -DiskNumber $diskNumber -PartitionNumber $partNumber -Size $supportedSize.SizeMax
        $newSize = [math]::Round((Get-Partition -DriveLetter $driveLetter).Size / 1GB, 2)
        Write-Host "SUCCESS: C: drive successfully expanded to ${newSize} GB"
    } catch {
        Write-Host "ERROR: Failed to resize partition: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "C: drive is already at maximum size - no resize needed"
}
