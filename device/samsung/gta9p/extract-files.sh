#!/bin/bash
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Extraction script for Samsung Galaxy Tab A9+ 5G (gta9p) proprietary blobs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENDOR_DIR="${SCRIPT_DIR}/../../../vendor/samsung/gta9p/proprietary"
SM6375_DIR="${SCRIPT_DIR}/../../../vendor/samsung/sm6375-common/proprietary"

# Check for firmware zip
FWZIP=""
for candidate in "$SCRIPT_DIR"/*.zip "$SCRIPT_DIR"/../../.././*.zip; do
    if [ -f "$candidate" ] && echo "$candidate" | grep -qi "SM-X216B\|X216B\|gta9p"; then
        FWZIP="$candidate"
        break
    fi
done

if [ -z "$FWZIP" ]; then
    echo "ERROR: No firmware zip found. Place the Samsung firmware zip in the repo root."
    exit 1
fi

echo "Using firmware: $FWZIP"

WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

echo "Extracting firmware zip..."
unzip -o "$FWZIP" -d "$WORK_DIR"

# Find and extract AP tar
AP_TAR=$(ls "$WORK_DIR"/AP_*.tar.md5 2>/dev/null | head -1)
if [ -z "$AP_TAR" ]; then
    AP_TAR=$(ls "$WORK_DIR"/AP_*.tar 2>/dev/null | head -1)
fi

if [ -n "$AP_TAR" ]; then
    echo "Extracting AP tar: $AP_TAR"
    tar xf "$AP_TAR" -C "$WORK_DIR"
fi

# Decompress lz4 files
cd "$WORK_DIR"
for f in *.lz4; do
    [ -f "$f" ] || continue
    out="${f%.lz4}"
    echo "Decompressing $f -> $out"
    lz4 -d "$f" "$out" 2>/dev/null || true
done

# Convert super.img if sparse
if [ -f super.img ]; then
    if file super.img | grep -q "Android sparse image"; then
        echo "Converting sparse super.img..."
        simg2img super.img super_raw.img
        SUPER=super_raw.img
    else
        SUPER=super.img
    fi

    echo "Unpacking super.img..."
    mkdir -p super_parts
    lpunpack "$SUPER" super_parts/ 2>/dev/null || true
fi

# Extract vendor partition
if [ -f super_parts/vendor.img ]; then
    echo "Extracting vendor partition..."
    mkdir -p vendor_dump
    fsck.erofs --extract=vendor_dump super_parts/vendor.img 2>/dev/null || \
        dump.erofs --path=. super_parts/vendor.img -d vendor_dump/ 2>/dev/null || true
fi

# Extract system_ext partition
if [ -f super_parts/system_ext.img ]; then
    echo "Extracting system_ext partition..."
    mkdir -p system_ext_dump
    fsck.erofs --extract=system_ext_dump super_parts/system_ext.img 2>/dev/null || true
fi

# Extract product partition
if [ -f super_parts/product.img ]; then
    echo "Extracting product partition..."
    mkdir -p product_dump
    fsck.erofs --extract=product_dump super_parts/product.img 2>/dev/null || true
fi

VENDOR_DUMP="$WORK_DIR/vendor_dump"

# Copy files based on proprietary-files.txt
copy_blobs() {
    local list_file="$1"
    local dest_dir="$2"
    local prefix="$3"

    if [ ! -f "$list_file" ]; then
        echo "Warning: $list_file not found"
        return
    fi

    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        relpath="${line#vendor/}"
        src="$VENDOR_DUMP/$relpath"
        dst="$dest_dir/$line"
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            echo "OK   $prefix: $line"
        else
            echo "MISS $prefix: $line"
        fi
    done < "$list_file"
}

echo ""
echo "=== Copying gta9p vendor blobs ==="
copy_blobs "${SCRIPT_DIR}/proprietary-files.txt" "$VENDOR_DIR" "gta9p"

echo ""
echo "=== Copying sm6375-common vendor blobs ==="
copy_blobs "${SCRIPT_DIR}/../../../device/samsung/sm6375-common/proprietary-files.txt" "$SM6375_DIR" "sm6375-common"

echo ""
echo "=== Extracting kernel modules ==="
MODULES_DEST="${SCRIPT_DIR}/prebuilt/modules"
mkdir -p "$MODULES_DEST"
find "$VENDOR_DUMP/lib/modules" -name "*.ko" 2>/dev/null | while read ko; do
    cp "$ko" "$MODULES_DEST/"
    echo "Module: $(basename "$ko")"
done

echo ""
echo "=== Copying mixer_paths.xml ==="
if [ -f "$VENDOR_DUMP/etc/mixer_paths.xml" ]; then
    cp "$VENDOR_DUMP/etc/mixer_paths.xml" "${SCRIPT_DIR}/../../../device/samsung/sm6375-common/audio/configs/"
    echo "OK: mixer_paths.xml"
fi

echo ""
echo "=== Copying WiFi firmware ==="
find "$VENDOR_DUMP/firmware/wlan" -type f 2>/dev/null | while read f; do
    rel="${f#$VENDOR_DUMP/}"
    dst="$VENDOR_DIR/$rel"
    mkdir -p "$(dirname "$dst")"
    cp "$f" "$dst"
done

echo ""
echo "=== Extraction complete ==="
echo "gta9p vendor files: $(find "$VENDOR_DIR" -type f 2>/dev/null | wc -l)"
echo "sm6375-common vendor files: $(find "$SM6375_DIR" -type f 2>/dev/null | wc -l)"
echo "Kernel modules: $(ls "$MODULES_DEST"/*.ko 2>/dev/null | wc -l)"
