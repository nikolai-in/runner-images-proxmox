################################################################################
##  File:  Debug-Network.ps1
##  Desc:  Emit network diagnostics early in provisioning.
##         Best-effort: does not fail provisioning.
################################################################################

$ErrorActionPreference = 'Continue'

Write-Host '===== Network diagnostics (start) ====='

Write-Host 'Hostname:'
hostname

Write-Host 'IP config:'
ipconfig /all

Write-Host 'Routes:'
route print

Write-Host 'Net adapters:'
Get-NetAdapter | Format-Table -AutoSize

Write-Host 'Net IP configuration:'
Get-NetIPConfiguration | Format-List

Write-Host 'DNS client server addresses:'
Get-DnsClientServerAddress | Format-Table -AutoSize

Write-Host 'Net IP interfaces:'
Get-NetIPInterface | Format-Table -AutoSize

Write-Host 'WinHTTP proxy:'
netsh winhttp show proxy

$testHosts = @(
    'raw.githubusercontent.com',
    'github.com',
    'api.github.com',
    'objects.githubusercontent.com',
    'download.docker.com',
    'www.microsoft.com'
)

foreach ($hostName in $testHosts) {
    Write-Host "DNS resolve ${hostName}:"
    try {
        Resolve-DnsName $hostName -ErrorAction Stop | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }

    Write-Host "Test-NetConnection ${hostName}:443:"
    try {
        Test-NetConnection -ComputerName $hostName -Port 443 | Format-List
    } catch {
        Write-Host $_
    }

    Write-Host "NSLookup ${hostName}:"
    try {
        nslookup $hostName
    } catch {
        Write-Host $_
    }

    Write-Host "Test-Connection ${hostName}:"
    try {
        Test-Connection -ComputerName $hostName -Count 2 -ErrorAction Stop | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }
}

Write-Host 'Default route (0.0.0.0/0):'
try {
    Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Format-Table -AutoSize
} catch {
    Write-Host $_
}

Write-Host 'Public IP (best-effort):'
$publicIpEndpoints = @(
    'https://api.ipify.org',
    'https://ifconfig.me/ip',
    'https://checkip.amazonaws.com'
)
foreach ($endpoint in $publicIpEndpoints) {
    Write-Host "Public IP via ${endpoint}:"
    try {
        Invoke-RestMethod -Uri $endpoint -ErrorAction Stop
    } catch {
        Write-Host $_
    }
}

Write-Host '===== Network diagnostics (end) ====='
