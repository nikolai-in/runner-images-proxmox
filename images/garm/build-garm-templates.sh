#!/usr/bin/env bash
set -euo pipefail

# Configuration Defaults
PROXMOX_NODE="${PROXMOX_NODE:-beelzebub}"
START_VMID="${GARM_VMID_START:-55000}"

# Define the templates to process
# Format: "Base_Template_Name | New_GARM_Template_Name | Packer_Source"
IMAGES=(
    "ubuntu-slim-runner|garm-ubuntu-slim-runner|proxmox-lxc.lxc"
    "ubuntu-runner-vm|garm-ubuntu-runner-vm|proxmox-clone.linux"
    "windows-2022-runner|garm-windows-2022-runner|proxmox-clone.windows"
)

# Navigate to the script's directory
cd "$(dirname "$0")"

if ! command -v packer &>/dev/null; then
    echo "ERROR: Packer is not installed or not in PATH."
    exit 1
fi

CURRENT_VMID=$START_VMID

for mapping in "${IMAGES[@]}"; do
    IFS='|' read -r CLONE_VM TEMPLATE_NAME BUILDER <<< "$mapping"

    echo ""
    echo "================================================================"
    echo "==> Building $TEMPLATE_NAME (VMID: $CURRENT_VMID) from $CLONE_VM"
    echo "================================================================"

    # Using PKR_VAR_* environment variables to pass inputs to Packer safely.
    # If a variable like `vm_id` is missing from `variables.garm.pkr.hcl`,
    # Packer will gracefully ignore it instead of throwing a strict error.
    export PKR_VAR_node="$PROXMOX_NODE"
    export PKR_VAR_clone_vm="$CLONE_VM"
    export PKR_VAR_template_name="$TEMPLATE_NAME"
    export PKR_VAR_vm_id="$CURRENT_VMID"

    packer build -only="garm-postprocess.$BUILDER" templates/

    CURRENT_VMID=$((CURRENT_VMID + 1))
done

echo ""
echo "==> Successfully processed all GARM templates! They are now ready for the provider."
