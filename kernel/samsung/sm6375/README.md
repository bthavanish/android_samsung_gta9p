# Kernel Source for Samsung Galaxy Tab A9+ 5G (SM-X216B)

This directory contains the kernel source for the gta9p device.

## Prebuilt Kernel

The prebuilt kernel images are located at:
- `device/samsung/gta9p/prebuilt/Image` — Kernel image
- `device/samsung/gta9p/prebuilt/dtb.img` — Device tree blob
- `device/samsung/gta9p/prebuilt/dtbo.img` — Device tree overlay
- `device/samsung/gta9p/prebuilt/ramdisk.cpio` — Initial ramdisk

## Building from Source

To build the kernel from source, place the Samsung kernel source in this directory:

```bash
# Clone Samsung kernel source (or extract from firmware)
git clone https://github.com/Samsung-Exynos/android_kernel_samsung_sm6375.git kernel/samsung/sm6375

# Or extract from firmware
./scripts/extract-kernel.sh /path/to/firmware.zip
```

## Kernel Version

- Kernel: 5.4.x
- Platform: Qualcomm SM6375 (Snapdragon 695 5G)
- Architecture: arm64

## Modules

Kernel modules are listed in `device/samsung/gta9p/modules.load`.
These must be extracted from the stock firmware.
