################################################################################
##  File:  Optimize-BaseImage.ps1
##  Desc:  Minimize disk space usage of the Windows base image so that the
##         resulting Proxmox template is as small as possible.
##
##  Run this script AFTER Windows Updates are installed and a restart has
##  completed. The operations it performs are destructive/irreversible (e.g.
##  DISM /ResetBase removes superseded update components permanently).
##
##  Space savings per step (approximate):
##    - Disable hibernation:            = installed RAM (e.g. 8 GB for 8 GB RAM)
##    - WU download cache:              1-3 GB
##    - DISM /StartComponentCleanup:    2-5 GB
##    - Temp / Prefetch / Logs:         < 1 GB
##    - Zero free space:                reclaims thin-provisioned storage blocks
################################################################################

# 1. Disable hibernation - removes hiberfil.sys, which is the same size as RAM
Write-Output "Disabling hibernation (removes hiberfil.sys)"
powercfg /hibernate off

# 2. Clean Windows Update download cache
Write-Output "Stopping Windows Update service"
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Write-Output "Removing Windows Update download cache"
Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" `
    -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "Restarting Windows Update service"
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# 3. DISM component store cleanup
# /StartComponentCleanup + /ResetBase removes all superseded component versions.
# This cannot be undone, and rollback of already-installed updates is no longer
# possible afterwards - acceptable for a read-only base template.
Write-Output "Running DISM component store cleanup (this may take several minutes)"
$dismArgs = "/online /Cleanup-Image /StartComponentCleanup /ResetBase"
$dismProc = Start-Process -FilePath "dism.exe" -ArgumentList $dismArgs `
    -NoNewWindow -Wait -PassThru
if ($dismProc.ExitCode -ne 0) {
    Write-Warning "DISM exited with code $($dismProc.ExitCode) - continuing"
}

# 4. Remove CBS logs left by Windows Update / DISM
Write-Output "Removing CBS logs"
Remove-Item "$env:SystemRoot\Logs\CBS\*" -Recurse -Force -ErrorAction SilentlyContinue

# 5. Clear temporary files and Prefetch
Write-Output "Clearing temporary files"
@(
    "$env:SystemRoot\Temp\*",
    "$env:SystemRoot\Prefetch\*",
    "$env:TEMP\*",
    "$env:TMP\*"
) | ForEach-Object {
    Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
}

# 6. Clear Windows event logs
Write-Output "Clearing Windows event logs"
Get-WinEvent -ListLog * -Force -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName)
    } catch {
        Write-Verbose "Non-fatal: could not clear a protected log."
    }
}

# 7. Zero out free disk space so Proxmox thin-provisioned storage can reclaim
# blocks. On LVM-thin or directory storage with qcow2, this allows the host
# to discard pages written to during update/cleanup operations.
#
# We write a file of zeros to fill free space, then delete it. The NtfsDisable8Dot3NameCreation
# registry flag is not affected; the file is written in chunks so memory
# pressure is bounded regardless of disk size.
Write-Output "Writing zeros to free disk space for thin-provisioning reclamation"
$drives = Get-PSDrive -PSProvider FileSystem |
    Where-Object { $_.Free -gt 256MB } |
    Select-Object -ExpandProperty Root

foreach ($drive in $drives) {
    $zeroFile = Join-Path $drive "zero_$(New-Guid).tmp"
    Write-Output "  Filling free space on ${drive} (approx. $([math]::Round((Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq $drive }).Free / 1GB, 1)) GB)"
    try {
        $fs = [System.IO.File]::Open($zeroFile, 'Create', 'Write', 'None')
        $chunk = New-Object byte[] (4MB)   # 4 MB zero-filled chunks
        try {
            while ($true) { $fs.Write($chunk, 0, $chunk.Length) }
        } catch [System.IO.IOException] {
            Write-Verbose "Disk full - expected"
        }
    } finally {
        if ($null -ne $fs) { $fs.Dispose() }
        Remove-Item $zeroFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Output "Optimize-BaseImage complete"
