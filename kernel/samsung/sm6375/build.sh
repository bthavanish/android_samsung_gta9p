#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Build script for Samsung SM6375 (GKI) kernel
#
# This script builds the kernel from source. The full kernel source
# must be cloned separately (see README.md).
#
# Usage:
#   ./build.sh              # Build kernel
#   ./build.sh defconfig    # Generate merged defconfig only
#   ./build.sh clean        # Clean build output
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're in the kernel source tree or the device tree
if [ -f "Makefile" ] && head -1 Makefile | grep -q "Kernel"; then
    KERNEL_SRC="$SCRIPT_DIR"
elif [ -d "../sm6375-source" ]; then
    KERNEL_SRC="$(cd .. && pwd)/sm6375-source"
else
    echo "ERROR: Kernel source not found."
    echo ""
    echo "Please clone the kernel source first:"
    echo "  git clone --depth=1 -b lineage-22.2 \\"
    echo "      https://github.com/Samsung-QTI/android_kernel_samsung_sm6375-common.git \\"
    echo "      $(dirname "$SCRIPT_DIR")/sm6375-source"
    echo ""
    echo "Then copy the defconfig files:"
    echo "  cp $SCRIPT_DIR/arch/arm64/configs/vendor/samsung/gta9p.config \\"
    echo "     $KERNEL_SRC/arch/arm64/configs/vendor/samsung/"
    exit 1
fi

echo "Using kernel source: $KERNEL_SRC"

# Toolchain settings
export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_COMPAT=arm-linux-gnueabi-

# Paths
OUT_DIR="${SCRIPT_DIR}/out"
DEFCONFIG_DIR="${KERNEL_SRC}/arch/arm64/configs"
VENDOR_DIR="${DEFCONFIG_DIR}/vendor"
SAMSUNG_DIR="${VENDOR_DIR}/samsung"

# Defconfig fragments (in order)
GKI_DEFCONFIG="${DEFCONFIG_DIR}/gki_defconfig"
HOLI_QGKI_DEFCONFIG="${VENDOR_DIR}/holi-qgki_defconfig"
HOLI_QGKI_CONFIG="${VENDOR_DIR}/holi_QGKI.config"
GTA9P_CONFIG="${SAMSUNG_DIR}/gta9p.config"

MERGED_DEFCONFIG="${OUT_DIR}/defconfig_merged"

# Prebuilt images
PREBUILT_DIR="${SCRIPT_DIR}/prebuilt"

print_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  (none)      Build kernel and modules"
    echo "  defconfig   Generate merged defconfig only"
    echo "  clean       Clean build output"
    echo "  modules     Build kernel modules only"
    echo ""
}

check_toolchain() {
    echo "Checking toolchain..."
    if ! command -v clang &> /dev/null; then
        echo "ERROR: clang not found. Install clang or use AOSP prebuilts."
        echo "  export PATH=/path/to/clang/bin:\$PATH"
        exit 1
    fi
    echo "  clang: $(clang --version | head -1)"
}

merge_defconfig() {
    echo "Merging defconfig fragments..."
    mkdir -p "$OUT_DIR"

    # Start with GKI base config
    cp "$GKI_DEFCONFIG" "${OUT_DIR}/.config"

    # Apply each fragment
    for fragment in "$HOLI_QGKI_DEFCONFIG" "$HOLI_QGKI_CONFIG" "$GTA9P_CONFIG"; do
        if [ -f "$fragment" ]; then
            echo "  Applying: $(basename "$fragment")"
            cat "$fragment" | grep -v "^#" | grep -v "^$" >> "${OUT_DIR}/.config"
        else
            echo "  WARNING: Fragment not found: $fragment"
        fi
    done

    # Run olddefconfig to resolve any dependencies
    make O="$OUT_DIR" olddefconfig

    # Save merged defconfig
    cp "${OUT_DIR}/.config" "$MERGED_DEFCONFIG"
    echo "  Merged defconfig saved to: $MERGED_DEFCONFIG"
}

build_kernel() {
    echo "Building kernel..."
    check_toolchain

    # Generate defconfig if not present
    if [ ! -f "$MERGED_DEFCONFIG" ]; then
        merge_defconfig
    fi

    # Build kernel
    make O="$OUT_DIR" -j$(nproc) \
        ARCH="$ARCH" \
        CC="$CC" \
        CLANG_TRIPLE="$CLANG_TRIPLE" \
        CROSS_COMPILE="$CROSS_COMPILE" \
        Image dtbs modules 2>&1 | tail -20

    # Copy prebuilts
    echo "Copying build artifacts to prebuilt/..."
    if [ -f "${OUT_DIR}/arch/arm64/boot/Image" ]; then
        cp "${OUT_DIR}/arch/arm64/boot/Image" "$PREBUILT_DIR/Image"
        echo "  Image copied"
    fi

    if [ -f "${OUT_DIR}/arch/arm64/boot/dtbo.img" ]; then
        cp "${OUT_DIR}/arch/arm64/boot/dtbo.img" "$PREBUILT_DIR/dtbo.img"
        echo "  dtbo.img copied"
    fi

    echo "Kernel build complete!"
}

build_modules() {
    echo "Building kernel modules..."
    check_toolchain

    if [ ! -f "$MERGED_DEFCONFIG" ]; then
        merge_defconfig
    fi

    make O="$OUT_DIR" -j$(nproc) \
        ARCH="$ARCH" \
        CC="$CC" \
        CLANG_TRIPLE="$CLANG_TRIPLE" \
        CROSS_COMPILE="$CROSS_COMPILE" \
        modules

    echo "Modules built. Install with:"
    echo "  make O=$OUT_DIR INSTALL_MOD_PATH=$OUT_DIR/lib/modules modules_install"
}

clean_build() {
    echo "Cleaning build output..."
    rm -rf "$OUT_DIR"
    echo "Clean complete."
}

# Main
case "${1:-}" in
    defconfig)
        merge_defconfig
        ;;
    clean)
        clean_build
        ;;
    modules)
        build_modules
        ;;
    -h|--help|help)
        print_usage
        ;;
    *)
        build_kernel
        ;;
esac
