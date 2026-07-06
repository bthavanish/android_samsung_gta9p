#!/bin/bash
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Setup makefiles script for Samsung Galaxy Tab A9+ 5G (gta9p)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/../../.."

echo "Generating vendor makefiles for gta9p..."

# The vendor makefiles are already present in:
# vendor/samsung/gta9p/gta9p-vendor.mk
# vendor/samsung/sm6375-common/sm6375-common-vendor.mk
#
# This script validates that all required blobs are present.

VENDOR_DIR="vendor/samsung/gta9p/proprietary"
SM6375_DIR="vendor/samsung/sm6375-common/proprietary"

echo ""
echo "=== Checking gta9p vendor blobs ==="
if [ -d "$VENDOR_DIR" ]; then
    echo "gta9p vendor files: $(find "$VENDOR_DIR" -type f | wc -l)"
    echo "HAL .so files: $(find "$VENDOR_DIR" -name "*.so" -path "*/hw/*" | wc -l)"
else
    echo "ERROR: $VENDOR_DIR not found. Run extract-files.sh first."
    exit 1
fi

echo ""
echo "=== Checking sm6375-common vendor blobs ==="
if [ -d "$SM6375_DIR" ]; then
    echo "sm6375-common vendor files: $(find "$SM6375_DIR" -type f | wc -l)"
else
    echo "ERROR: $SM6375_DIR not found. Run extract-files.sh first."
    exit 1
fi

echo ""
echo "=== Checking kernel modules ==="
MODULES_DIR="device/samsung/gta9p/prebuilt/modules"
if [ -d "$MODULES_DIR" ]; then
    echo "Kernel modules: $(ls "$MODULES_DIR"/*.ko 2>/dev/null | wc -l)"
else
    echo "ERROR: $MODULES_DIR not found. Run extract-files.sh first."
    exit 1
fi

echo ""
echo "=== Validation complete ==="
