################################################################################
##  File:  RunAll-Tests-Slim.ps1
##  Desc:  Runs Pester tests for the slim image variant.
##         Executes only the test files relevant to the slim build; test files
##         for tools not installed in the slim image are intentionally omitted.
##         Excluded: Android, Apache, Databases, Haskell, Miniconda, Nginx,
##                   PHP, SSDTExtensions, WDK, WinAppDriver.
################################################################################

$ErrorActionPreference = 'Stop'

# Refresh environment variables so PATH changes from previous provisioners
# are visible to the current shell before tests run.
Update-Environment

$slimTestFiles = @(
    "ActionArchiveCache",
    "Browsers",
    "ChocoPackages",
    "CLI.Tools",
    "Docker",
    "DotnetSDK",
    "Git",
    "Java",
    "LLVM",
    "MSYS2",
    "Node",
    "PipxPackages",
    "PowerShellAzModules",
    "PowerShellModules",
    "RunnerCache",
    "Rust",
    "Shell",
    "Tools",
    "Toolset",
    "VisualStudio",
    "Vsix",
    "WindowsFeatures",
    "Wix"
) | ForEach-Object { "C:\image\tests\${_}.Tests.ps1" }

$configuration = [PesterConfiguration] @{
    Run        = @{ Path = $slimTestFiles; PassThru = $true }
    Output     = @{ Verbosity = "Detailed"; RenderMode = "Plaintext" }
    TestResult = @{ Enabled = $true; OutputPath = "C:\image\tests\testResults.xml" }
}

$backupErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$results = Invoke-Pester -Configuration $configuration
$ErrorActionPreference = $backupErrorActionPreference

if (-not ($results -and ($results.FailedCount -eq 0) -and ($results.PassedCount -gt 0))) {
    $results
    throw "Test run has failed"
}
