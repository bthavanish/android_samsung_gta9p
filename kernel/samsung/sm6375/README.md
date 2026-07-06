# Kernel Source for Samsung Galaxy Tab A9+ 5G (SM-X216B)

This directory contains the kernel configuration and prebuilt images for the
gta9p device. The full kernel source is in a separate repository.

## Kernel Version

- **Base**: Linux 5.4.249 (GKI LTS)
- **Platform**: Qualcomm SM6375 (Snapdragon 695 5G / holi)
- **Architecture**: arm64
- **GKI Version**: LTS_5.4.249_d57e792d0bd9

## Defconfig Chain

The kernel configuration is built from multiple fragments applied in order:

1. `arch/arm64/configs/gki_defconfig` — Base GKI config
2. `arch/arm64/configs/vendor/holi-qgki_defconfig` — Qualcomm QGKI platform config
3. `arch/arm64/configs/vendor/holi_QGKI.config` — QGKI overlay
4. `arch/arm64/configs/vendor/samsung/gta9p.config` — Device-specific config

## Directory Structure

```
kernel/samsung/sm6375/
├── arch/arm64/configs/        # Defconfig files
│   ├── gki_defconfig          # Base GKI config
│   └── vendor/
│       ├── holi-qgki_defconfig  # Qualcomm platform config
│       ├── holi_QGKI.config     # QGKI overlay
│       └── samsung/
│           └── gta9p.config     # Device-specific config
├── prebuilt/                  # Prebuilt kernel images
│   ├── Image                  # Kernel image
│   ├── dtb.img                # Device tree blob
│   ├── dtbo.img               # Device tree overlay
│   └── ramdisk.cpio           # Initial ramdisk
├── build.sh                   # Build script (requires full kernel source)
└── README.md                  # This file
```

## Building from Source

### Prerequisites

- Clang/LLVM toolchain (AOSP prebuilts recommended)
- `flex`, `bison`, `libssl-dev`, `libelf-dev`

### Step 1: Clone Full Kernel Source

```bash
git clone --depth=1 -b lineage-22.2 \
    https://github.com/Samsung-QTI/android_kernel_samsung_sm6375-common.git \
    kernel/samsung/sm6375-source
```

### Step 2: Apply Device Config

```bash
cd kernel/samsung/sm6375-source

# Copy defconfig chain
cp ../sm6375/arch/arm64/configs/gki_defconfig arch/arm64/configs/
cp ../sm6375/arch/arm64/configs/vendor/holi-qgki_defconfig arch/arm64/configs/vendor/
cp ../sm6375/arch/arm64/configs/vendor/holi_QGKI.config arch/arm64/configs/vendor/
cp ../sm6375/arch/arm64/configs/vendor/samsung/gta9p.config arch/arm64/configs/vendor/samsung/
```

### Step 3: Build

```bash
export ARCH=arm64
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-

# Merge defconfig
scripts/kconfig/merge_config.sh \
    arch/arm64/configs/gki_defconfig \
    arch/arm64/configs/vendor/holi-qgki_defconfig \
    arch/arm64/configs/vendor/holi_QGKI.config \
    arch/arm64/configs/vendor/samsung/gta9p.config

# Build kernel
make -j$(nproc) Image dtbs modules

# Copy prebuilts
cp arch/arm64/boot/Image ../sm6375/prebuilt/
cp arch/arm64/boot/dtbo.img ../sm6375/prebuilt/
```

### Using AOSP Toolchain

```bash
export PATH=/path/to/aosp/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH
```

## Prebuilt Images

Prebuilt images in `prebuilt/` are used as the default. They are extracted
from the stock firmware (SM-X216BXXS9DYJ7).

## Kernel Modules

Kernel modules are listed in `device/samsung/gta9p/modules.load`.
Prebuilt modules are in `device/samsung/gta9p/prebuilt/modules/`.

## Source

- **Common kernel**: [Samsung-QTI/android_kernel_samsung_sm6375-common](https://github.com/Samsung-QTI/android_kernel_samsung_sm6375-common) (lineage-22.2)
- **GKI base**: android.git.kernel.org/kernel/common (LTS 5.4.249)
- **Platform**: Qualcomm holi (SM6375) BSP
