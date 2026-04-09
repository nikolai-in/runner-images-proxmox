using module ./software-report-base/SoftwareReport.psm1
using module ./software-report-base/SoftwareReport.Nodes.psm1

$global:ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue"
$ErrorView = "NormalView"
Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Browsers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.CachedTools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Common.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Tools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Java.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.VisualStudio.psm1") -DisableNameChecking

# Software report
$softwareReport = [SoftwareReport]::new($(Build-OSInfoSection))
$optionalFeatures = $softwareReport.Root.AddHeader("Windows features")
$optionalFeatures.AddToolVersion("Windows Subsystem for Linux (WSLv1):", "Enabled")
$installedSoftware = $softwareReport.Root.AddHeader("Installed Software")

# Language and Runtime
# Julia, Kotlin, PHP, Perl are not installed in the slim image.
$languageAndRuntime = $installedSoftware.AddHeader("Language and Runtime")
$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))
$languageAndRuntime.AddToolVersion("Go", $(Get-GoVersion))
$languageAndRuntime.AddToolVersion("LLVM", $(Get-LLVMVersion))
$languageAndRuntime.AddToolVersion("Node", $(Get-NodeVersion))
$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))
$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))

# Package Management
# Composer (PHP), Helm, Miniconda are not installed in the slim image.
$packageManagement = $installedSoftware.AddHeader("Package Management")
$packageManagement.AddToolVersion("Chocolatey", $(Get-ChocoVersion))
$packageManagement.AddToolVersion("NPM", $(Get-NPMVersion))
$packageManagement.AddToolVersion("NuGet", $(Get-NugetVersion))
$packageManagement.AddToolVersion("pip", $(Get-PipVersion))
$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))
$packageManagement.AddToolVersion("RubyGems", $(Get-RubyGemsVersion))
$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))
$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))

$packageManagement.AddHeader("Environment variables").AddTable($(Build-PackageManagementEnvironmentTable))

# Project Management
# Ant, Gradle, sbt are not installed in the slim image.
$projectManagement = $installedSoftware.AddHeader("Project Management")
$projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))

# Tools
# The following are not installed in the slim image:
#   azcopy, Bazel, Bazelisk, Bicep, Cabal, ghc, ImageMagick, Kind, Kubectl,
#   Mercurial, Pulumi, R, Service Fabric SDK, Stack, Subversion, WinAppDriver.
$tools = $installedSoftware.AddHeader("Tools")
$tools.AddToolVersion("7zip", $(Get-7zipVersion))
$tools.AddToolVersion("aria2", $(Get-Aria2Version))
$tools.AddToolVersion("CMake", $(Get-CMakeVersion))
$tools.AddToolVersion("CodeQL Action Bundle", $(Get-CodeQLBundleVersion))
$tools.AddToolVersion("Docker", $(Get-DockerVersion))
$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeVersionV2))
$tools.AddToolVersion("Docker-wincred", $(Get-DockerWincredVersion))
$tools.AddToolVersion("Git", $(Get-GitVersion))
$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))
$tools.AddToolVersion("InnoSetup", $(Get-InnoSetupVersion))
$tools.AddToolVersion("jq", $(Get-JQVersion))
$tools.AddToolVersion("gcc", $(Get-GCCVersion))
$tools.AddToolVersion("gdb", $(Get-GDBVersion))
$tools.AddToolVersion("GNU Binutils", $(Get-GNUBinutilsVersion))
$tools.AddToolVersion("Newman", $(Get-NewmanVersion))
$tools.AddToolVersion("NSIS", $(Get-NSISVersion))
$tools.AddToolVersion("OpenSSL", $(Get-OpenSSLVersion))
$tools.AddToolVersion("Packer", $(Get-PackerVersion))
$tools.AddToolVersion("Swig", $(Get-SwigVersion))
$tools.AddToolVersion("VSWhere", $(Get-VSWhereVersion))
$tools.AddToolVersion("WiX Toolset", $(Get-WixVersion))
$tools.AddToolVersion("yamllint", $(Get-YAMLLintVersion))
$tools.AddToolVersion("zstd", $(Get-ZstdVersion))
$tools.AddToolVersion("Ninja", $(Get-NinjaVersion))

# CLI Tools
# Alibaba Cloud CLI, AWS CLI, AWS SAM CLI, AWS Session Manager CLI,
# Azure CLI, and Azure DevOps CLI extension are not installed in the slim image.
$cliTools = $installedSoftware.AddHeader("CLI Tools")
$cliTools.AddToolVersion("GitHub CLI", $(Get-GHVersion))

# Rust Tools
Initialize-RustEnvironment
$rustTools = $installedSoftware.AddHeader("Rust Tools")
$rustTools.AddToolVersion("Cargo", $(Get-RustCargoVersion))
$rustTools.AddToolVersion("Rust", $(Get-RustVersion))
$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))
$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))

$rustToolsPackages = $rustTools.AddHeader("Packages")
$rustToolsPackages.AddToolVersion("bindgen", $(Get-BindgenVersion))
$rustToolsPackages.AddToolVersion("cargo-audit", $(Get-CargoAuditVersion))
$rustToolsPackages.AddToolVersion("cargo-outdated", $(Get-CargoOutdatedVersion))
$rustToolsPackages.AddToolVersion("cbindgen", $(Get-CbindgenVersion))
$rustToolsPackages.AddToolVersion("Clippy", $(Get-RustClippyVersion))
$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))

# Browsers and Drivers
$browsersAndWebdrivers = $installedSoftware.AddHeader("Browsers and Drivers")
$browsersAndWebdrivers.AddNodes($(Build-BrowserSection))
$browsersAndWebdrivers.AddHeader("Environment variables").AddTable($(Build-BrowserWebdriversEnvironmentTable))

# Java
$installedSoftware.AddHeader("Java").AddTable($(Get-JavaVersions))

# Shells
$installedSoftware.AddHeader("Shells").AddTable($(Get-ShellTarget))

# MSYS2
$msys2 = $installedSoftware.AddHeader("MSYS2")
$msys2.AddToolVersion("Pacman", $(Get-PacmanVersion))

$notes = @'
Location: C:\msys64

Note: MSYS2 is pre-installed on image but not added to PATH.
'@
$msys2.AddHeader("Notes").AddNote($notes)

# Cached Tools
$installedSoftware.AddHeader("Cached Tools").AddNodes($(Build-CachedToolsSection))

# Visual Studio
$vsTable = Get-VisualStudioVersion
$visualStudio = $installedSoftware.AddHeader($vsTable.Name)
$visualStudio.AddTable($vsTable)

$workloads = $visualStudio.AddHeader("Workloads, components and extensions")
$workloads.AddTable((Get-VisualStudioComponents) + (Get-VisualStudioExtensions))

$msVisualCpp = $visualStudio.AddHeader("Microsoft Visual C++")
$msVisualCpp.AddTable($(Get-VisualCPPComponents))

$visualStudio.AddToolVersionsList("Installed Windows SDKs", $(Get-WindowsSDKs).Versions, '^.+')

# .NET Core Tools
$netCoreTools = $installedSoftware.AddHeader(".NET Core Tools")
$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotnetSdks).Versions, '^\d+\.\d+\.\d{3}')
$netCoreTools.AddToolVersionsListInline(".NET Framework", $(Get-DotnetFrameworkVersions), '^.+')
Get-DotnetRuntimes | ForEach-Object {
    $netCoreTools.AddToolVersionsListInline($_.Runtime, $_.Versions, '^.+')
}
$netCoreTools.AddNodes($(Get-DotnetTools))

# PowerShell Tools
$psTools = $installedSoftware.AddHeader("PowerShell Tools")
$psTools.AddToolVersion("PowerShell", $(Get-PowershellCoreVersion))

$psModules = $psTools.AddHeader("Powershell Modules")
$psModules.AddNodes($(Get-PowerShellModules))

# Generate reports
$softwareReport.ToJson() | Out-File -FilePath "C:\software-report.json" -Encoding UTF8NoBOM
$softwareReport.ToMarkdown() | Out-File -FilePath "C:\software-report.md" -Encoding UTF8NoBOM
