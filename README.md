# PixelOS for Samsung Galaxy Tab A9+ 5G (SM-X216B)

Self-contained device tree for building PixelOS (Android 16 QPR2) for the
Samsung Galaxy Tab A9+ 5G. This repo contains everything needed to build
except the PixelOS/AOSP framework source.

## Device Specifications

| Spec | Value |
|------|-------|
| Device | Samsung Galaxy Tab A9+ 5G |
| Model | SM-X216B |
| Codename | gta9p |
| Platform | Qualcomm SM6375 (Snapdragon 695 5G) |
| Architecture | arm64 (primary), arm (secondary) |
| Display | 1200x1920 IPS LCD, 450 DPI |
| RAM | 8 GB |
| Storage | 128 GB |
| Battery | 7040 mAh |
| Android | 15 (stock firmware X216BXXS9DYJ7) |
| Security Patch | 2025-10-01 |

## Repository Structure

```
android_samsung_gta9p/
├── device/samsung/gta9p/          # Device-specific configs
├── device/samsung/sm6375-common/  # Platform common configs
├── vendor/samsung/gta9p/          # Device vendor blobs
│   └── proprietary/vendor/        # Extracted blobs go here
├── vendor/samsung/sm6375-common/  # Platform vendor blobs
│   └── proprietary/vendor/        # Extracted blobs go here
├── kernel/samsung/sm6375/         # Kernel source (placeholder)
├── prebuilts/                     # Prebuilt tools (cloned at build)
├── tools/                         # Extract utils (cloned at build)
├── recovery/                      # Recovery sources
└── .github/workflows/             # CI/CD for blob extraction
```

## Building

### Prerequisites

- Linux (Ubuntu 22.04 recommended)
- 16 GB+ RAM
- 200 GB+ free disk space
- Android SDK and build tools

### Quick Start

```bash
# Initialize PixelOS source
repo init -u https://github.com/PixelOS-AOSP/android -b sixteen-qpr2
repo sync -c -j$(nproc --all)

# Clone this device tree (contains everything)
git clone https://github.com/bthavanish/android_samsung_gta9p.git \
  device/samsung/gta9p

# Extract vendor blobs (from firmware dump or device)
cd device/samsung/gta9p
./extract-files.sh /path/to/firmware-dump

# Or use GitHub Actions (recommended)
# Go to Actions > Extract Vendor Blobs > Run workflow

# Build
source build/envsetup.sh
lunch pixelos_gta9p-userdebug
mka bacon
```

### Extracting Vendor Blobs

#### Option A: GitHub Actions (Recommended)

1. Create a firmware dump repository with extracted partition images
2. Go to Actions > Extract Vendor Blobs > Run workflow
3. Provide your firmware dump repo URL
4. The workflow will extract blobs and commit to this repo

#### Option B: Local Extraction from Firmware

```bash
# Extract partition images from Samsung firmware zip
./scripts/extract-firmware.sh /path/to/SM-X216B_INS_X216BXXS9DYJ7_fac.zip

# Extract blobs from the partitions
cd device/samsung/sm6375-common
./extract-files.sh ../../firmware-dump/
cd ../gta9p
./extract-files.sh ../../firmware-dump/
```

#### Option C: ADB Extraction (Device Required)

```bash
# Enable USB debugging on the device
# Connect via USB and extract blobs directly
cd device/samsung/sm6375-common
./extract-files.sh
cd ../gta9p
./extract-files.sh
```

## Kernel

The prebuilt kernel images are in `device/samsung/gta9p/prebuilt/`:
- `Image` — Kernel image (PE/COFF format)
- `dtb.img` — Device tree blob
- `dtbo.img` — Device tree overlay
- `ramdisk.cpio` — Initial ramdisk

To build from source, place the Samsung kernel source in `kernel/samsung/sm6375/`.

## Flashing

```bash
# Boot to fastboot
adb reboot bootloader

# Flash boot image, vendor_boot, and dtbo
fastboot flash boot out/target/product/gta9p/boot.img
fastboot flash vendor_boot out/target/product/gta9p/vendor_boot.img
fastboot flash dtbo out/target/product/gta9p/dtbo.img

# Disable AVB verification (required for custom ROM)
fastboot flash vbmeta out/target/product/gta9p/vbmeta.img \
  --disable-verity --disable-verification

# Flash system partitions
fastboot flash system out/target/product/gta9p/system.img
fastboot flash vendor out/target/product/gta9p/vendor.img
fastboot flash product out/target/product/gta9p/product.img
fastboot flash system_ext out/target/product/gta9p/system_ext.img

fastboot reboot
```

## Status

| Feature | Status |
|---------|--------|
| Boot | Working (needs blob extraction) |
| Display | Untested |
| WiFi | Untested |
| Bluetooth | Untested |
| Camera | Untested |
| Audio | Untested |
| NFC | Untested |
| Telephony | Untested |
| Fingerprint | N/A (no fingerprint sensor) |

## Known Issues

- Vendor blobs must be extracted before building
- Kernel modules (.ko files) need to be extracted from stock firmware
- Some sepolicy rules may need to be added after first boot

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on actual hardware
5. Submit a pull request

## Credits

- [PixelOS Project](https://github.com/PixelOS-AOSP)
- [LineageOS](https://wiki.lineageos.org/) for reference device trees and extract-utils
- [Samsung](https://www.samsung.com/) for the firmware

## License

Apache License 2.0
