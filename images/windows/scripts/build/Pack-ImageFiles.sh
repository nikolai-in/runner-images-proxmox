#!/usr/bin/env bash
################################################################################
##  File:  Pack-ImageFiles.sh
##  Desc:  Creates a single zip archive (/tmp/packer-image-files.zip) from all
##         image source directories.
##
##         WinRM has ~7–8 s of overhead *per file*, so uploading 150+ scripts
##         individually takes ~20 minutes.  Compressing everything into one
##         archive and uploading the single zip cuts that to under a minute.
##
##  Layout inside the zip mirrors the expected layout under C:\image\:
##    assets/        <- images/windows/assets/
##    scripts/       <- images/windows/scripts/
##    toolsets/      <- images/windows/toolsets/
##    scripts/docs-gen/software-report-base/
##                   <- helpers/software-report-base/
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HELPERS_DIR="$(cd "${IMAGES_DIR}/../.." && pwd)/helpers"
ZIP_PATH="/tmp/packer-image-files.zip"

STAGING="$(mktemp -d)"
cleanup() { rm -rf "${STAGING}"; }
trap cleanup EXIT

echo "Packing image files for upload..."

cp -r "${IMAGES_DIR}/assets"   "${STAGING}/"
cp -r "${IMAGES_DIR}/scripts"  "${STAGING}/"
cp -r "${IMAGES_DIR}/toolsets" "${STAGING}/"

# software-report-base must land at C:\image\scripts\docs-gen\software-report-base\
# after Expand-Archive, matching what the separate file provisioner used to produce.
mkdir -p "${STAGING}/scripts/docs-gen"
cp -r "${HELPERS_DIR}/software-report-base" "${STAGING}/scripts/docs-gen/"

rm -f "${ZIP_PATH}"
(cd "${STAGING}" && zip -qr "${ZIP_PATH}" .)

echo "Created ${ZIP_PATH} ($(du -sh "${ZIP_PATH}" | cut -f1))"
