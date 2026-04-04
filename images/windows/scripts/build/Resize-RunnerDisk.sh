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

RESIZE_RESPONSE=$(curl -sf -k -X PUT \
  "${BASE_URL}/api2/json/nodes/${PROXMOX_NODE}/qemu/${VMID}/resize" \
  -b "PVEAuthCookie=${TICKET}" \
  -H "CSRFPreventionToken: ${CSRF}" \
  --data-urlencode "disk=scsi0" \
  --data-urlencode "size=${DISK_SIZE}")

printf '%s' "${RESIZE_RESPONSE}"
echo ""

UPID=$(printf '%s' "${RESIZE_RESPONSE}" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['data'])")

echo "Disk resize request sent successfully (UPID: ${UPID})"
echo "Waiting for resize task to complete..."

# URL-encode the UPID (colons must be percent-encoded for the path segment)
UPID_ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "${UPID}")

POLL_INTERVAL=5
MAX_WAIT=300   # 5 minutes
elapsed=0

while true; do
  TASK_STATUS=$(curl -sf -k \
    "${BASE_URL}/api2/json/nodes/${PROXMOX_NODE}/tasks/${UPID_ENCODED}/status" \
    -b "PVEAuthCookie=${TICKET}" | \
    python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d['status'], d.get('exitstatus',''))")

  STATUS=$(echo "${TASK_STATUS}" | awk '{print $1}')
  EXIT_STATUS=$(echo "${TASK_STATUS}" | awk '{print $2}')

  if [ "${STATUS}" = "stopped" ]; then
    if [ "${EXIT_STATUS}" = "OK" ]; then
      echo "Disk resize completed successfully"
      break
    else
      echo "ERROR: Disk resize task failed with exit status: ${EXIT_STATUS}"
      exit 1
    fi
  fi

  elapsed=$((elapsed + POLL_INTERVAL))
  if [ "${elapsed}" -ge "${MAX_WAIT}" ]; then
    echo "ERROR: Timed out waiting for disk resize after ${MAX_WAIT}s"
    exit 1
  fi

  echo "  Task status: ${STATUS} (${elapsed}s elapsed, retrying in ${POLL_INTERVAL}s...)"
  sleep "${POLL_INTERVAL}"
done
