function Get-ToolcacheGoVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Go"
    if (-not (Test-Path $toolcachePath)) { return @() }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcacheNodeVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Node"
    if (-not (Test-Path $toolcachePath)) { return @() }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcachePythonVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Python"
    if (-not (Test-Path $toolcachePath)) { return @() }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcacheRubyVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Ruby"
    if (-not (Test-Path $toolcachePath)) { return @() }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcachePyPyVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "PyPy"
    if (-not (Test-Path $toolcachePath)) { return @() }
    Get-ChildItem -Path $toolcachePath -Name | Sort-Object { [Version] $_ } | ForEach-Object {
        $pypyRootPath = Join-Path $toolcachePath $_ "x86"
        [string] $pypyVersionOutput = & "$pypyRootPath\python.exe" -c "import sys;print(sys.version)"
        $pypyVersionOutput -match "^([\d\.]+) \(.+\) \[PyPy ([\d\.]+\S*) .+]$" | Out-Null
        return "{0} [PyPy {1}]" -f $Matches[1], $Matches[2]
    }
}

function Build-CachedToolsSection
{
    $nodes = @()

    $goVersions = Get-ToolcacheGoVersions
    if ($goVersions) { $nodes += [ToolVersionsListNode]::new("Go", @($goVersions), '^\d+\.\d+', 'List') }

    $nodeVersions = Get-ToolcacheNodeVersions
    if ($nodeVersions) { $nodes += [ToolVersionsListNode]::new("Node.js", @($nodeVersions), '^\d+', 'List') }

    $pythonVersions = Get-ToolcachePythonVersions
    if ($pythonVersions) { $nodes += [ToolVersionsListNode]::new("Python", @($pythonVersions), '^\d+\.\d+', 'List') }

    $pypyVersions = Get-ToolcachePyPyVersions
    if ($pypyVersions) { $nodes += [ToolVersionsListNode]::new("PyPy", @($pypyVersions), '^\d+\.\d+', 'List') }

    $rubyVersions = Get-ToolcacheRubyVersions
    if ($rubyVersions) { $nodes += [ToolVersionsListNode]::new("Ruby", @($rubyVersions), '^\d+\.\d+', 'List') }

    return $nodes
}
