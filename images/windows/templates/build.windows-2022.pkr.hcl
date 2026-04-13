// Windows Server 2022 Build Configuration
//
// Normal build: packer build -only="windows-2022.proxmox-clone.runner" -var="image_os=win22" .
// Debug build:  packer build -only="windows-2022.null.winrm" -var="image_os=win22" -var="winrm_host=IP" .

build {
  sources = [
    "source.proxmox-clone.runner",
    "source.null.winrm"
  ]
  name = "windows-2022"

  provisioner "powershell" {
    inline = [
      "New-Item -Path ${var.image_folder} -ItemType Directory -Force",
      "New-Item -Path ${var.temp_dir} -ItemType Directory -Force"
    ]
  }

  provisioner "file" {
    only        = ["null.winrm"]
    destination = "${var.image_folder}\\"
    sources = [
      "${path.root}/../assets",
      "${path.root}/../scripts",
      "${path.root}/../toolsets"
    ]
  }

  provisioner "file" {
    only        = ["null.winrm"]
    destination = "${var.image_folder}\\scripts\\docs-gen\\"
    source      = "${path.root}/../../../helpers/software-report-base"
  }

  // For proxmox-clone builds the assets/scripts/toolsets are delivered via the
  // ImageFiles ISO (additional_iso_files in source.windows.pkr.hcl) instead of
  // slow WinRM file transfer.  The CD is mounted as a sata drive; we detect it
  // by its volume label so the drive letter does not need to be hard-coded.
  //
  // No 'only' filter here: the script runs for every source but gracefully
  // no-ops when the ImageFiles volume is absent (null.winrm debug builds
  // deliver files via WinRM file provisioners instead).
  provisioner "powershell" {
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}"]
    script           = "${path.root}/../scripts/build/Copy-ImageFilesFromISO.ps1"
  }

  provisioner "powershell" {
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "if (Test-Path 'C:\\post-generation') { Remove-Item -Recurse -Force 'C:\\post-generation' }",
      "Move-Item -Force '${var.image_folder}\\assets\\post-gen' 'C:\\post-generation'",
      "Remove-Item -Recurse -Force '${var.image_folder}\\assets'",
      "if (Test-Path '${var.image_folder}\\SoftwareReport') { Remove-Item -Recurse -Force '${var.image_folder}\\SoftwareReport' }",
      "Move-Item -Force '${var.image_folder}\\scripts\\docs-gen' '${var.image_folder}\\SoftwareReport'",
      "if (Test-Path '${var.helper_script_folder}\\ImageHelpers') { Remove-Item -Recurse -Force '${var.helper_script_folder}\\ImageHelpers' }",
      "Move-Item -Force '${var.image_folder}\\scripts\\helpers' '${var.helper_script_folder}\\ImageHelpers'",
      "New-Item -Type Directory -Force -Path '${var.helper_script_folder}\\TestsHelpers\\'",
      "Move-Item -Force '${var.image_folder}\\scripts\\tests\\Helpers.psm1' '${var.helper_script_folder}\\TestsHelpers\\TestsHelpers.psm1'",
      "if (Test-Path '${var.image_folder}\\tests') { Remove-Item -Recurse -Force '${var.image_folder}\\tests' }",
      "Move-Item -Force '${var.image_folder}\\scripts\\tests' '${var.image_folder}\\tests'",
      "Remove-Item -Recurse -Force '${var.image_folder}\\scripts'",
      "Move-Item -Force '${var.image_folder}\\toolsets\\toolset-2022.json' '${var.image_folder}\\toolset.json'",
      "Remove-Item -Recurse -Force '${var.image_folder}\\toolsets'"
    ]
  }

  provisioner "windows-shell" {
    inline = [
      "net user ${var.install_user} ${var.install_password} /add /passwordchg:no /passwordreq:yes /active:yes /Y",
      "net localgroup Administrators ${var.install_user} /add",
      "winrm set winrm/config/service/auth @{Basic=\"true\"}",
      "winrm get winrm/config/service/auth"
    ]
  }

  provisioner "powershell" {
    inline = ["if (-not ((net localgroup Administrators) -contains '${var.install_user}')) { exit 1 }"]
  }

  provisioner "powershell" {
    elevated_password = "${var.install_password}"
    elevated_user     = "${var.install_user}"
    inline            = ["bcdedit.exe /set TESTSIGNING ON"]
  }

  provisioner "powershell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_OS=${var.image_os}", "AGENT_TOOLSDIRECTORY=${var.agent_tools_directory}", "IMAGEDATA_FILE=${var.imagedata_file}", "IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    execution_policy = "unrestricted"
    scripts = [
      "${path.root}/../scripts/build/Configure-WindowsDefender.ps1",
      "${path.root}/../scripts/build/Configure-PowerShell.ps1",
      "${path.root}/../scripts/build/Install-PowerShellModules.ps1",
      "${path.root}/../scripts/build/Install-WindowsFeatures.ps1",
      "${path.root}/../scripts/build/Install-Chocolatey.ps1",
      "${path.root}/../scripts/build/Configure-BaseImage.ps1",
      "${path.root}/../scripts/build/Configure-ImageDataFile.ps1",
      "${path.root}/../scripts/build/Configure-SystemEnvironment.ps1",
      "${path.root}/../scripts/build/Configure-DotnetSecureChannel.ps1"
    ]
  }

  provisioner "windows-restart" {
    check_registry        = true
    restart_check_command = "powershell -command \"& {while ( (Get-WindowsOptionalFeature -Online -FeatureName Containers -ErrorAction SilentlyContinue).State -ne 'Enabled' ) { Start-Sleep 30; Write-Output 'InProgress' }}\""
    restart_timeout       = "10m"
  }

  provisioner "powershell" {
    inline = ["Set-Service -Name wlansvc -StartupType Manual", "if ($(Get-Service -Name wlansvc).Status -eq 'Running') { Stop-Service -Name wlansvc}"]
  }

  provisioner "powershell" {
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-Docker.ps1",
      "${path.root}/../scripts/build/Install-DockerWinCred.ps1",
      "${path.root}/../scripts/build/Install-DockerCompose.ps1",
      "${path.root}/../scripts/build/Install-PowershellCore.ps1",
      "${path.root}/../scripts/build/Install-WebPlatformInstaller.ps1",
      "${path.root}/../scripts/build/Install-Runner.ps1",
      "${path.root}/../scripts/build/Install-TortoiseSvn.ps1"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    elevated_password = "${var.install_password}"
    elevated_user     = "${var.install_user}"
    environment_vars  = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-VisualStudio.ps1",
      "${path.root}/../scripts/build/Install-KubernetesTools.ps1"
    ]
    valid_exit_codes = [0, 3010]
  }

  provisioner "windows-restart" {
    check_registry  = true
    restart_timeout = "10m"
  }

  provisioner "powershell" {
    pause_before     = "2m0s"
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-Wix.ps1",
      "${path.root}/../scripts/build/Install-WDK.ps1",
      "${path.root}/../scripts/build/Install-VSExtensions.ps1",
      "${path.root}/../scripts/build/Install-AzureCli.ps1",
      "${path.root}/../scripts/build/Install-AzureDevOpsCli.ps1",
      "${path.root}/../scripts/build/Install-ChocolateyPackages.ps1",
      "${path.root}/../scripts/build/Install-JavaTools.ps1",
      "${path.root}/../scripts/build/Install-Kotlin.ps1",
      "${path.root}/../scripts/build/Install-OpenSSL.ps1"
    ]
  }

  provisioner "powershell" {
    execution_policy = "remotesigned"
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts          = ["${path.root}/../scripts/build/Install-ServiceFabricSDK.ps1"]
  }

  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  provisioner "windows-shell" {
    inline = ["wmic product where \"name like '%%microsoft azure powershell%%'\" call uninstall /nointeractive"]
  }

  provisioner "powershell" {
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-ActionsCache.ps1",
      "${path.root}/../scripts/build/Install-Ruby.ps1",
      "${path.root}/../scripts/build/Install-PyPy.ps1",
      "${path.root}/../scripts/build/Install-Toolset.ps1",
      "${path.root}/../scripts/build/Configure-Toolset.ps1",
      "${path.root}/../scripts/build/Install-NodeJS.ps1",
      "${path.root}/../scripts/build/Install-AndroidSDK.ps1",
      "${path.root}/../scripts/build/Install-PowershellAzModules.ps1",
      "${path.root}/../scripts/build/Install-Pipx.ps1",
      "${path.root}/../scripts/build/Install-Git.ps1",
      "${path.root}/../scripts/build/Install-GitHub-CLI.ps1",
      "${path.root}/../scripts/build/Install-PHP.ps1",
      "${path.root}/../scripts/build/Install-Rust.ps1",
      "${path.root}/../scripts/build/Install-Sbt.ps1",
      "${path.root}/../scripts/build/Install-Chrome.ps1",
      "${path.root}/../scripts/build/Install-EdgeDriver.ps1",
      "${path.root}/../scripts/build/Install-Firefox.ps1",
      "${path.root}/../scripts/build/Install-Selenium.ps1",
      "${path.root}/../scripts/build/Install-IEWebDriver.ps1",
      "${path.root}/../scripts/build/Install-Apache.ps1",
      "${path.root}/../scripts/build/Install-Nginx.ps1",
      "${path.root}/../scripts/build/Install-Msys2.ps1",
      "${path.root}/../scripts/build/Install-WinAppDriver.ps1",
      "${path.root}/../scripts/build/Install-R.ps1",
      "${path.root}/../scripts/build/Install-AWSTools.ps1",
      "${path.root}/../scripts/build/Install-DACFx.ps1",
      "${path.root}/../scripts/build/Install-MysqlCli.ps1",
      "${path.root}/../scripts/build/Install-SQLPowerShellTools.ps1",
      "${path.root}/../scripts/build/Install-SQLOLEDBDriver.ps1",
      "${path.root}/../scripts/build/Install-DotnetSDK.ps1",
      "${path.root}/../scripts/build/Install-Mingw64.ps1",
      "${path.root}/../scripts/build/Install-Haskell.ps1",
      "${path.root}/../scripts/build/Install-Stack.ps1",
      "${path.root}/../scripts/build/Install-Miniconda.ps1",
      "${path.root}/../scripts/build/Install-AzureCosmosDbEmulator.ps1",
      "${path.root}/../scripts/build/Install-Mercurial.ps1",
      "${path.root}/../scripts/build/Install-Zstd.ps1",
      "${path.root}/../scripts/build/Install-NSIS.ps1",
      "${path.root}/../scripts/build/Install-Vcpkg.ps1",
      "${path.root}/../scripts/build/Install-PostgreSQL.ps1",
      "${path.root}/../scripts/build/Install-Bazel.ps1",
      "${path.root}/../scripts/build/Install-AliyunCli.ps1",
      "${path.root}/../scripts/build/Install-RootCA.ps1",
      "${path.root}/../scripts/build/Install-MongoDB.ps1",
      "${path.root}/../scripts/build/Install-CodeQLBundle.ps1",
      "${path.root}/../scripts/build/Configure-Diagnostics.ps1"
    ]
  }

  provisioner "powershell" {
    elevated_password = "${var.install_password}"
    elevated_user     = "${var.install_user}"
    environment_vars  = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-WindowsUpdates.ps1",
      "${path.root}/../scripts/build/Configure-DynamicPort.ps1",
      "${path.root}/../scripts/build/Configure-GDIProcessHandleQuota.ps1",
      "${path.root}/../scripts/build/Configure-Shell.ps1",
      "${path.root}/../scripts/build/Configure-DeveloperMode.ps1",
      "${path.root}/../scripts/build/Install-LLVM.ps1"
    ]
  }

  provisioner "windows-restart" {
    check_registry        = true
    restart_check_command = "powershell -command \"& {if ((-not (Get-Process TiWorker.exe -ErrorAction SilentlyContinue)) -and (-not [System.Environment]::HasShutdownStarted) ) { Write-Output 'Restart complete' }}\""
    restart_timeout       = "30m"
  }

  provisioner "powershell" {
    pause_before     = "2m0s"
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    scripts = [
      "${path.root}/../scripts/build/Install-WindowsUpdatesAfterReboot.ps1",
      "${path.root}/../scripts/build/Invoke-Cleanup.ps1",
      "${path.root}/../scripts/tests/RunAll-Tests.ps1"
    ]
  }

  provisioner "powershell" {
    inline = ["if (-not (Test-Path ${var.image_folder}\\tests\\testResults.xml)) { throw '${var.image_folder}\\tests\\testResults.xml not found' }"]
  }

  provisioner "powershell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_FOLDER=${var.image_folder}"]
    inline           = ["pwsh -File '${var.image_folder}\\SoftwareReport\\Generate-SoftwareReport.ps1'"]
  }

  provisioner "powershell" {
    inline = ["if (-not (Test-Path C:\\software-report.md)) { throw 'C:\\software-report.md not found' }", "if (-not (Test-Path C:\\software-report.json)) { throw 'C:\\software-report.json not found' }"]
  }

  provisioner "file" {
    destination = "${path.root}/../Windows2022-Readme.md"
    direction   = "download"
    source      = "C:\\software-report.md"
  }

  provisioner "file" {
    destination = "${path.root}/../software-report.json"
    direction   = "download"
    source      = "C:\\software-report.json"
  }

  provisioner "powershell" {
    environment_vars = ["INSTALL_USER=${var.install_user}"]
    scripts = [
      "${path.root}/../scripts/build/Install-NativeImages.ps1",
      "${path.root}/../scripts/build/Configure-System.ps1",
      "${path.root}/../scripts/build/Configure-User.ps1",
      "${path.root}/../scripts/build/Post-Build-Validation.ps1"
    ]
    skip_clean = true
  }

  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  provisioner "powershell" {
    inline = [
      "Set-Service cloudbase-init -StartupType Automatic",
      "Write-Output \"Skipping Sysprep for faster CI/CD spin-up time.\""
    ]
  }

}