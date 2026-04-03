#!/usr/bin/env bash
# Resize-RunnerDisk.sh
# Expand the OS disk (scsi0) of a Proxmox VM via the REST API.
#
# Usage: Resize-RunnerDisk.sh <vmid>
#
# Required environment variables (set by the Packer shell-local provisioner):
#   PROXMOX_URL   — Proxmox API base URL, e.g. https://pve:8006/api2/json
#   PROXMOX_USER  — Proxmox username, e.g. root@pam
#   PROXMOX_PASS  — Proxmox password
#   PROXMOX_NODE  — Proxmox node name, e.g. pve
#   DISK_SIZE     — Target disk size with unit suffix, e.g. 200G
set -euo pipefail

VMID="${1:?VMID argument is required}"

# Normalise the base URL: strip trailing /api2/json or trailing slash
BASE_URL="${PROXMOX_URL%/api2/json}"
BASE_URL="${BASE_URL%/}"

# Obtain an auth ticket and CSRF token
AUTH_RESPONSE=$(curl -sf -k -X POST "${BASE_URL}/api2/json/access/ticket" \
  --data-urlencode "username=${PROXMOX_USER}" \
  --data-urlencode "password=${PROXMOX_PASS}")

TICKET=$(printf '%s' "${AUTH_RESPONSE}" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['data']['ticket'])")
CSRF=$(printf '%s' "${AUTH_RESPONSE}" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['data']['CSRFPreventionToken'])")

echo "Resizing VM ${VMID} scsi0 to ${DISK_SIZE} on node ${PROXMOX_NODE}"

curl -sf -k -X PUT \
  "${BASE_URL}/api2/json/nodes/${PROXMOX_NODE}/qemu/${VMID}/resize" \
  -b "PVEAuthCookie=${TICKET}" \
  -H "CSRFPreventionToken: ${CSRF}" \
  --data-urlencode "disk=scsi0" \
  --data-urlencode "size=${DISK_SIZE}"

echo "Disk resize request sent successfully"
