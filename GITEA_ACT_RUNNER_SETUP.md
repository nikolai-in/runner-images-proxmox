# Gitea Act Runner and Cloudbase-Init Integration

This document outlines the configuration changes made to support Gitea `act_runner` natively across Ubuntu and Windows Proxmox templates, optimize Windows CI/CD boot times, and ensure seamless integration with the GARM Proxmox provider.

## Overview of changes

### 1. Act Runner service installation
Gitea `act_runner` is now baked into the runner templates alongside the standard GitHub Actions runner.
- **Ubuntu/Ubuntu-Slim**: A new script (`install-act-runner.sh`) downloads the binary to `/home/runner/act_runner` and configures a systemd service (`act_runner.service`) to run as the `runner` user.
- **Windows**: `Install-Runner.ps1` downloads the executable directly from the Gitea S3 CDN (`dl.gitea.com`) to bypass Cloudflare API redirects. It uses Chocolatey to install `NSSM` (Non-Sucking Service Manager) and configures `act_runner` as an automatic background service.

### 2. Fast-booting Windows runners (Sysprep bypassed)
Historically, Windows Packer templates concluded with a `Sysprep.exe /oobe /generalize` pass. While useful for domain-joined machines, Sysprep adds 2-4 minutes of boot time, which is detrimental to ephemeral CI/CD environments.
- Sysprep has been removed from all `build.windows-*.pkr.hcl` templates.
- Packer now simply sets the `cloudbase-init` service to start automatically and powers off the VM.
- Windows runners now boot in 10-15 seconds.

### 3. Cloudbase-Init configuration fixes
To ensure `cloudbase-init` boots quickly and executes GARM payloads without hanging, the base configuration (`images/windows/assets/base/config/cloudbase-init.conf` and `cloudbase-init-unattend.conf`) was updated:
- **Metadata scoping**: Removed `HttpService`, `EC2Service`, and `MaaSHttpService` from `metadata_services`. It now exclusively looks for `ConfigDriveService`, preventing 15-minute network timeout hangs during boot.
- **Plugin enablement**: Added the `UserDataPlugin` to the `plugins` list. Without this, `cloudbase-init` silently ignores the PowerShell scripts injected by GARM.
- **Deprecation cleanup**: Replaced legacy `logdir` and `logfile` keys with `log-dir` and `log-file`.

### 4. GARM Proxmox Provider updates
The `cloud_init.py` logic in the GARM provider was updated to natively support `act_runner` configurations.
- When GARM detects a Gitea/Forgejo forge, it instructs the runner to generate a `config.yaml` file (`act_runner generate-config`).
- GARM updates the service daemon parameters (systemd `ExecStart` on Linux, NSSM `AppParameters` on Windows) to append `--config config.yaml`, ensuring runner capacity and caching configurations are respected.

---

## How GARM interacts with Cloudbase-Init

When you trigger a workflow in Gitea or GitHub, GARM spins up an ephemeral VM on Proxmox. Here is the exact sequence of how GARM and Cloudbase-Init interact to bootstrap the runner:

### Step 1: Payload generation
GARM determines the target OS and the forge type. It generates a provisioning script (a Bash `#cloud-config` for Linux, or a `#ps1_sysnative` PowerShell script for Windows). This script contains the API URL, the registration token, and runner labels.

### Step 2: ConfigDrive attachment
GARM instructs Proxmox to clone the requested VM template. During the clone process, GARM attaches a **ConfigDrive** (a small virtual CD-ROM/ISO) to the VM. This drive contains the generated script in a file named `user-data`.

### Step 3: Cloudbase-Init execution
When the Windows VM boots:
1. The **Cloudbase-Init Service** starts automatically.
2. The `ConfigDriveService` module scans attached CD-ROMs and detects the Proxmox ConfigDrive.
3. The `UserDataPlugin` reads the `user-data` file. Recognizing the `#ps1_sysnative` header, it executes the payload as a 64-bit PowerShell script.

### Step 4: Runner registration and start
The executing GARM script performs the final setup:
1. Calls the GARM metadata URL to fetch the final ephemeral runner token.
2. Generates the default `config.yaml`.
3. Runs `act_runner.exe register` using the token and config.
4. Updates the NSSM service to include the `--config` flag and starts the `act_runner` service.
5. Sends a callback webhook back to GARM to report the runner is `running`.

> [!NOTE]  
> Because Sysprep is no longer used, Proxmox clones retain their generalized state perfectly, allowing Cloudbase-Init to handle hostname generation and network initialization within seconds of the VM powering on.
