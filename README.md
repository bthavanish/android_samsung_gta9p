# PixelOS for Samsung Galaxy Tab A9+ 5G (SM-X216B)

Device tree for building PixelOS (Android 16 QPR2) for the Samsung Galaxy
Tab A9+ 5G, codename `gta9p`.

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

## Building

### Prerequisites

- Linux (Ubuntu 22.04 recommended)
- 16 GB+ RAM
- 200 GB+ free disk space
- Android SDK and build tools

### Setup

```bash
# Initialize PixelOS source
repo init -u https://github.com/PixelOS-AOSP/android -b sixteen-qpr2
repo sync -c -j$(nproc --all)

# Clone device tree
git clone https://github.com/bthavanish/android_samsung_gta9p.git \
  device/samsung/gta9p
git clone https://github.com/bthavanish/android_samsung_sm6375-common.git \
  device/samsung/sm6375-common

# Clone vendor tree (after extracting blobs)
git clone https://github.com/bthavanish/vendor_samsung_gta9p.git \
  vendor/samsung/gta9p
```

### Extracting Vendor Blobs

You need the proprietary vendor blobs from the stock firmware.

#### Option A: From firmware zip (local)

```bash
# Extract partition images from Samsung firmware zip
./scripts/extract-firmware.sh /path/to/SM-X216B_INS_X216BXXS9DYJ7_fac.zip

# Extract blobs from the partitions
cd device/samsung/sm6375-common
./extract-files.sh ../../firmware-dump/
cd ../gta9p
./extract-files.sh ../../firmware-dump/

# Generate vendor makefiles
cd device/samsung/sm6375-common && ./setup-makefiles.sh
cd device/samsung/gta9p && ./setup-makefiles.sh
```

#### Option B: Via ADB (device required)

```bash
# Enable USB debugging on the device
# Connect via USB and extract blobs directly
cd device/samsung/sm6375-common
./extract-files.sh
cd ../gta9p
./extract-files.sh
```

#### Option C: GitHub Actions

1. Create a firmware dump repository with extracted partition images
2. Go to Actions > Extract Vendor Blobs > Run workflow
3. Provide your firmware dump repo URL
4. The workflow will extract blobs and create the vendor tree

### Build

```bash
source build/envsetup.sh
lunch pixelos_gta9p-userdebug
mka bacon
```

The build output will be in `out/target/product/gta9p/`.

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

# Flash system partitions (if using system-as-root)
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
- [LineageOS](https://wiki.lineageos.org/) for reference device trees
- [Samsung](https://www.samsung.com/) for the firmware

## License

Apache License 2.0
