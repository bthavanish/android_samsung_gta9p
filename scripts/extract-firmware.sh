#!/bin/bash
# extract-firmware.sh — Extract partition images from Samsung firmware zip
#
# Usage:
#   ./scripts/extract-firmware.sh <firmware.zip> [output-dir]
#
# This script extracts the partition images (system, vendor, product, etc.)
# from a Samsung firmware zip file. The extracted images can then be used
# with extract-files.sh or uploaded to a firmware dump repository.
#
# Requirements:
#   - Python 3.8+
#   - unzip
#   - file
#
# For super.img extraction, you also need:
#   - simg2img (for sparse images)
#   - lpunpack (for LP metadata)
#   OR
#   - The Python script handles Samsung's compressed super format

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

FIRMWARE_ZIP="${1:-}"
OUTPUT_DIR="${2:-$REPO_DIR/firmware-dump}"

if [ -z "$FIRMWARE_ZIP" ]; then
    echo "Usage: $0 <firmware.zip> [output-dir]"
    echo ""
    echo "Extracts partition images from Samsung firmware zip."
    echo "Output can be used with extract-files.sh or uploaded as firmware dump."
    exit 1
fi

if [ ! -f "$FIRMWARE_ZIP" ]; then
    echo "ERROR: Firmware zip not found: $FIRMWARE_ZIP"
    exit 1
fi

echo "=== Samsung Firmware Extractor ==="
echo "Input:  $FIRMWARE_ZIP"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR/extracted"

# Step 1: Extract the firmware zip
echo "=== Step 1: Extracting firmware zip ==="
EXTRACT_DIR=$(mktemp -d)
trap "rm -rf $EXTRACT_DIR" EXIT

unzip -q "$FIRMWARE_ZIP" -d "$EXTRACT_DIR" || {
    echo "ERROR: Failed to extract firmware zip"
    exit 1
}

echo "Extracted files:"
find "$EXTRACT_DIR" -type f -name "*.img" | sort
echo ""

# Step 2: Find and process super.img
echo "=== Step 2: Processing super.img ==="
SUPER_IMG=$(find "$EXTRACT_DIR" -name "super.img" -type f | head -1)

if [ -n "$SUPER_IMG" ]; then
    echo "Found super.img: $SUPER_IMG"

    # Check if it's a sparse image
    FILE_TYPE=$(file "$SUPER_IMG")
    echo "File type: $FILE_TYPE"

    if echo "$FILE_TYPE" | grep -q "Android sparse image"; then
        echo "Converting sparse image to raw..."
        RAW_SUPER="$OUTPUT_DIR/extracted/super.raw.img"
        if command -v simg2img &>/dev/null; then
            simg2img "$SUPER_IMG" "$RAW_SUPER"
        else
            echo "WARNING: simg2img not found, trying Python conversion..."
            python3 "$SCRIPT_DIR/sparse2raw.py" "$SUPER_IMG" "$RAW_SUPER" 2>/dev/null || {
                echo "ERROR: Cannot convert sparse image. Install simg2img:"
                echo "  sudo apt install simg2img"
                echo "  OR: pip install simg2img"
                exit 1
            }
        fi
        SUPER_IMG="$RAW_SUPER"
    fi

    # Try to extract partitions using lpunpack
    if command -v lpunpack &>/dev/null; then
        echo "Extracting partitions with lpunpack..."
        lpunpack "$SUPER_IMG" "$OUTPUT_DIR/extracted/"
    else
        echo "WARNING: lpunpack not found. Attempting Python extraction..."
        python3 "$SCRIPT_DIR/extract_super.py" "$SUPER_IMG" "$OUTPUT_DIR/extracted/" 2>/dev/null || {
            echo "WARNING: Python extraction failed"
            echo "Install lpunpack or use the Samsung compressed super extraction:"
            echo "  sudo apt install lpunpack"
        }
    fi

    # List extracted partitions
    echo ""
    echo "Extracted partitions:"
    ls -lh "$OUTPUT_DIR/extracted/"*.img 2>/dev/null || echo "  (none)"
else
    echo "No super.img found in firmware zip"
fi

# Step 3: Copy other images
echo ""
echo "=== Step 3: Copying other images ==="
for img in boot.img vendor_boot.img dtbo.img vbmeta.img vbmeta_system.img; do
    FOUND=$(find "$EXTRACT_DIR" -name "$img" -type f | head -1)
    if [ -n "$FOUND" ]; then
        echo "  Copying $img..."
        cp "$FOUND" "$OUTPUT_DIR/"
    fi
done

# Step 4: Extract kernel modules
echo ""
echo "=== Step 4: Looking for kernel modules ==="
find "$EXTRACT_DIR" -name "*.ko" -type f | while read -r ko; do
    KO_NAME=$(basename "$ko")
    echo "  Found: $KO_NAME"
done

# Step 5: Copy partition images to final location
echo ""
echo "=== Step 5: Organizing output ==="
for part in system vendor product system_ext odm; do
    for img in "$OUTPUT_DIR/extracted/${part}.img" "$EXTRACT_DIR/${part}.img"; do
        if [ -f "$img" ]; then
            cp "$img" "$OUTPUT_DIR/${part}.img"
            echo "  ${part}.img: $(du -h "$img" | cut -f1)"
            break
        fi
    done
done

# Copy other partitions
for part in cache persist efs sec_efs metadata; do
    for img in "$OUTPUT_DIR/extracted/${part}.img" "$EXTRACT_DIR/${part}.img"; do
        if [ -f "$img" ]; then
            cp "$img" "$OUTPUT_DIR/${part}.img"
            echo "  ${part}.img: $(du -h "$img" | cut -f1)"
            break
        fi
    done
done

# Step 6: Summary
echo ""
echo "=== Extraction Complete ==="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Files:"
ls -lh "$OUTPUT_DIR/"*.img 2>/dev/null | while read -r line; do
    echo "  $line"
done

echo ""
echo "Next steps:"
echo "  1. Upload the output directory to a GitHub repository:"
echo "     cd $OUTPUT_DIR"
echo "     git init"
echo "     git add ."
echo "     git commit -m 'firmware dump for gta9p'"
echo "     gh repo create <your-repo> --public --source=. --push"
echo ""
echo "  2. Run the GitHub Actions workflow:"
echo "     Go to Actions > Extract Vendor Blobs > Run workflow"
echo "     Provide your firmware dump repo URL"
echo ""
echo "  OR extract locally:"
echo "     cd $REPO_DIR"
echo "     ./device/samsung/sm6375-common/extract-files.sh $OUTPUT_DIR"
echo "     ./device/samsung/gta9p/extract-files.sh $OUTPUT_DIR"
