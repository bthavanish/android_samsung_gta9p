# Remaining Work — SM-X216B (gta9p) PixelOS Device Tree

## Status

The device tree skeleton is complete and committed. What follows is every
blocking and non-blocking task still required before the tree can be built,
flashed, and used as a daily driver. Each section lists the exact files
affected, what needs to change, and why.

---

## 1. Extract Vendor Blobs from Firmware (BLOCKING)

This repo is self-contained — all vendor blobs are stored here under
`vendor/samsung/gta9p/proprietary/vendor/` and
`vendor/samsung/sm6375-common/proprietary/vendor/`.

The tree cannot build without the proprietary vendor blobs. The Samsung
compressed super.img cannot be mounted in Termux (no root, no simg2img, no
EROFS tools). This **must** be done on an x86_64 Linux machine with ADB
access to the device or with `simg2img` + `erofs-utils`.

### Option A: GitHub Actions (Recommended)

1. Create a firmware dump repository with extracted partition images.
2. Go to Actions > Extract Vendor Blobs > Run workflow.
3. Provide your firmware dump repo URL.
4. The workflow will extract blobs and commit them to THIS repo.

### Option B: Local Extraction (on an x86_64 machine)

1. Boot the device into Android (stock firmware X216BXXS9DYJ7).
2. Enable USB debugging, connect via ADB.
3. Run the extraction script:
   ```bash
   cd device/samsung/sm6375-common
   ./extract-files.sh
   ```
   This reads `proprietary-files.txt` and pulls each blob from the device
   into `vendor/samsung/sm6375-common/proprietary/vendor/`.

4. Then run the device-specific extraction:
   ```bash
   cd device/samsung/gta9p
   ./extract-files.sh
   ```
   This reads `device/samsung/gta9p/proprietary-files.txt` and populates
   `vendor/samsung/gta9p/proprietary/vendor/`.

5. After extraction, run `setup-makefiles.sh` in both directories to
   regenerate the vendor makefiles:
   ```bash
   cd device/samsung/sm6375-common && ./setup-makefiles.sh
   cd device/samsung/gta9p && ./setup-makefiles.sh
   ```

### Option C: Extract from firmware zip

```bash
./scripts/extract-firmware.sh /path/to/firmware.zip
```

### Option D: Extract from super.img on PC

If the device is not available, use a PC with Linux:

```bash
# Convert Samsung sparse super.img to raw
simg2img super.img super.raw.img

# Mount the raw image
mkdir /mnt/super
mount -o loop,ro super.raw.img /mnt/super

# Each partition is erofs — mount them individually
mount -o loop,ro /mnt/super/system.img /mnt/system
mount -o loop,ro /mnt/super/vendor.img /mnt/vendor
mount -o loop,ro /mnt/super/product.img /mnt/product
mount -o loop,ro /mnt/super/system_ext.img /mnt/system_ext
mount -o loop,ro /mnt/super/odm.img /mnt/odm
```

Then copy the blobs listed in `proprietary-files.txt` from the mounted
partitions into the appropriate `proprietary/vendor/` directories.

### Files affected

- `vendor/samsung/sm6375-common/proprietary/vendor/` (entire directory tree)
- `vendor/samsung/gta9p/proprietary/vendor/` (entire directory tree)

---

## 2. Fix device.mk — Remove Broken References (COMPLETED)

`device/samsung/gta9p/device.mk` has been cleaned up. Broken references
to non-existent audio configs and sensor packages have been removed.

---

## 3. Fix Recovery Files — Remove "(TODO)" from Filenames (COMPLETED)

Recovery files have been renamed and their content fixed to match the
stock fstab (erofs, fileencryption, avb_keys).
`rootdir/etc/fstab.qcom`). Also add the `avb_keys` and `fileencryption`
flags to match.

### Files affected

- `device/samsung/sm6375-common/recovery/root/fstab.qcom` (renamed)
- `device/samsung/sm6375-common/recovery/root/init.recovery.qcom.rc` (renamed)

---

## 4. Fix Duplicate Kernel Module Entry (COMPLETED)

Duplicate `qca_cld3_wlan.ko` entry has been removed from `modules.load`.

---

## 5. Verify kernel cmdline Matches Stock (COMPLETED)

Kernel cmdline has been verified against stock boot.img. The tree uses
`console=null` (intentional for userdebug builds) instead of stock's
`console=ttyMSM0,115200n8`. All other parameters match.

---

## 6. Add Kernel Modules (.ko files) to Prebuilt (BLOCKING)

The `modules.load` file lists 45 kernel modules, but none of the actual
`.ko` files exist in the prebuilt directory. These must be extracted from
the stock firmware's vendor_boot or vendor partition.

### How to extract

On a PC with the device or super.img mounted:

```bash
# Kernel modules are typically in:
# /vendor/lib/modules/
# /vendor/lib/modules/qualcomm/
# /vendor/lib/modules/qca_cld3/

# Copy all .ko files to:
mkdir -p device/samsung/gta9p/prebuilt/modules
cp /mnt/vendor/lib/modules/*.ko device/samsung/gta9p/prebuilt/modules/
```

Then update `BoardConfig.mk` to tell the build system where they are:

```makefile
# Add after TARGET_PREBUILT_KERNEL:
BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)
```

### Files affected

- `device/samsung/gta9p/prebuilt/modules/` (new directory, ~45 .ko files)
- `device/samsung/gta9p/BoardConfig.mk` (add BOARD_VENDOR_KERNEL_MODULES)

---

## 7. Verify and Update overlays (IMPORTANT)

The current overlays are minimal (just `config_screenDensityDpi`). The
stock firmware has many more device-specific resource overrides. Key items
to check:

### Framework overlays to add/verify

| Overlay | What it controls | Current status |
|---------|-----------------|----------------|
| `config_screenDensityDpi` | Display density | Set to 450 |
| `config_mainBuiltInDisplayPhysicalSize` | Physical display size | Missing — add 120x190mm (1200x1920 @ 450dpi) |
| `config_showNavigationBar` | Navigation bar | Missing — tablet may need true |
| `config_nfcFirmwareVersion` | NFC firmware path | Missing |
| `config_defaultAudioSafetyVolume` | Default audio volume | Missing |
| `config_tether_wifi_regexs` | WiFi tethering interfaces | Missing |
| `config_wifiP2pDeviceName` | P2P device name | Missing |

### SystemUI overlay

Check `sm6375-common/overlay/.../SystemUI/res/values/config.xml` for:
- `config_hasDisplayCutout` — tablet may not have one
- `config_statusBarKillButton` — should be false on tablet
- Lockscreen and notification settings

### Files affected

- `device/samsung/gta9p/overlay/frameworks/base/core/res/res/values/config.xml`
- `device/samsung/sm6375-common/overlay/frameworks/base/core/res/res/values/config.xml`
- `device/samsung/sm6375-common/overlay/frameworks/base/packages/SystemUI/res/values/config.xml`

---

## 8. Add Samsung-Specific sepolicy for Device (IMPORTANT)

The sepolicy in `sm6375-common/sepolicy/` covers the platform, but there
may be device-specific denials for the gta9p that need additional rules.

### After first boot

1. Boot the build, check for SELinux denials:
   ```bash
   adb logcat | grep "avc: denied"
   ```

2. Common Samsung-specific denials to expect:
   - `fingerprint` HAL accessing `/sys/devices/` nodes
   - `nfc` HAL accessing Samsung eSE paths
   - `sensors` HAL accessing specific sysfs nodes
   - `bluetooth` accessing `/data/vendor/bluetooth/`
   - `camera` accessing Samsung-specific camera firmware

3. Create device-specific `.te` files under:
   ```
   device/samsung/gta9p/sepolicy/vendor/
   ```

### Files affected (after first boot)

- `device/samsung/gta9p/sepolicy/` (new directory)

---

## 9. Clean Up Lineage-Specific Sepolicy (COMPLETED)

Lineage-specific sepolicy files (`hal_lineage_*.te`) have been removed.

---

## 10. Verify AVB (Verified Boot) Keys (IMPORTANT)

The tree uses test keys for AVB signing:

```makefile
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
```

This is fine for development but means:
- The device will boot with a warning on the bootloader screen
- OTA updates will not work with stock verification
- For production, generate new keys and sign properly

### For initial testing

Test keys are acceptable. For a release build:

```bash
# Generate AVB keys
external/avb/generate_keys_test_only --key_path device/samsung/gta9p/avb/
```

### Files affected

- `device/samsung/sm6375-common/BoardConfigCommon.mk` (AVB key paths)

---

## 11. Add Missing PRODUCT_COPY_FILES (MODERATE)

`common.mk` references several files from `frameworks/` that must exist in
the AOSP/PixelOS source tree. Verify these paths exist when building:

```
frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml
frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml
frameworks/av/services/audiopolicy/config/default_volume_tables.xml
frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml
frameworks/av/media/libstagefright/data/media_codecs_google_*.xml
frameworks/native/data/etc/android.hardware.*.xml
```

If building against PixelOS source, these should be present. If using a
minimal tree, they need to be provided.

### Files affected

- None directly — verify at build time

---

## 12. Test Build and Fix Compile Errors (BLOCKING)

After extracting blobs and fixing the above issues, attempt a build:

```bash
source build/envsetup.sh
lunch pixelos_gta9p-userdebug
mka bacon 2>&1 | tee build.log
```

### Expected issues to fix

1. **Missing header files** — Some vendor blobs reference headers not in
   the AOSP tree. Add stubs or adapt the `Android.bp` files.

2. **HIDL interface version mismatches** — The manifest declares @1.5
   radio but blobs may provide @1.2 or @1.4. Adjust manifest or blob
   selection.

3. **Camera HAL compile errors** — The Samsung camera provider uses Chi
   (Camera Hardware Interface) which requires specific Qualcomm camera
   libraries. Verify all camera blobs are present.

4. **Audio HAL compile errors** — The custom AIDL audio HAL in
   `audio/impl/` may need adjustments for the AIDL version in the
   build tree.

5. **SELinux policy compile errors** — `checkpolicy` will flag any
   undefined types or rules referencing missing attributes.

---

## 13. First Boot and Debug (BLOCKING)

After a successful build, flash and boot:

```bash
fastboot flash boot out/target/product/gta9p/boot.img
fastboot flash vendor_boot out/target/product/gta9p/vendor_boot.img
fastboot flash dtbo out/target/product/gta9p/dtbo.img
fastboot flash vbmeta out/target/product/gta9p/vbmeta.img --disable-verity --disable-verification
fastboot reboot
```

### What to check on first boot

| Issue | How to diagnose | Fix |
|-------|----------------|-----|
| Bootloop | `adb logcat -b all` during boot, look for kernel panics or init crashes | Check fstab, kernel cmdline, ramdisk |
| No display | Check `hwcomposer` and `surfaceflinger` logs | Verify gralloc/display blobs, DTB display node |
| No WiFi | `adb shell ip link show wlan0` | Verify `qca_cld3_wlan.ko` loads, WiFi firmware paths |
| No Bluetooth | `adb shell service list \| grep bluetooth` | Verify BT HAL service starts, check firmware |
| No sound | `adb shell dumpsys audio` | Check audio HAL, mixer paths, audio_policy_configuration.xml |
| No RIL | `adb shell getprop gsm.sim.state` | Verify radio HAL, RIL daemon, SIM detection |
| No NFC | `adb shell service list \| grep nfc` | Check NFC HAL, firmware paths, libnfc config |
| SELinux denials | `adb logcat \| grep "avc: denied"` | Add sepolicy rules per denial |
| Fingerprint | Check biometrics HAL | Verify fingerprint HAL service, TEE integration |

---

## 14. Refine Configs Based on Testing (ONGOING)

After first boot, several configs need tuning based on actual hardware
behavior:

### Audio

- `audio_effects.xml` — Verify effect library paths match extracted blobs
- `audio_policy_configuration.xml` — Verify mixer port counts and
  sampling rates match hardware capabilities
- `mixer_paths.xml` — May need Samsung-specific paths for speaker, earpiece

### Display

- Brightness levels, backlight interface path
- Display color profiles
- HWC layer limits

### Power

- `powerhint.json` — Tune for SM6375's big.LITTLE config
- CPU frequency scaling policies
- Suspend/resume behavior

### Camera

- Camera IDs and capabilities
- Resolution list in `media_profiles.xml`
- Video stabilization support

---

## 15. Documentation (LOW PRIORITY)

### README.md

Currently just a placeholder. Should include:

- Device name and codename
- Build instructions
- Known working / not working
- Download links (when available)
- Maintainer info

### Maintainer script

A script to automate blob extraction and build verification for future
updates:

```bash
#!/bin/bash
# scripts/update.sh — Pull blobs from new firmware and rebuild
```

---

## Summary of Blocking Items

| # | Task | Required for |
|---|------|-------------|
| 1 | Extract vendor blobs | Building |
| 2 | Fix device.mk broken refs | Building |
| 3 | Rename recovery (TODO) files | Recovery build |
| 4 | Fix duplicate module entry | Clean init |
| 6 | Extract kernel .ko modules | Boot |
| 12 | Fix compile errors | Building |
| 13 | First boot debug | Everything |

## Summary of Important (Non-Blocking) Items

| # | Task | Why |
|---|------|-----|
| 5 | Verify kernel cmdline | Boot reliability |
| 7 | Complete overlays | Display, features |
| 9 | Clean Lineage sepolicy | Code hygiene |
| 10 | AVB key decision | Security posture |
| 11 | Verify COPY_FILES paths | Build verification |

## Summary of Ongoing Items

| # | Task | When |
|---|------|------|
| 8 | Device-specific sepolicy | After first boot |
| 14 | Config tuning | After first boot |
| 15 | Documentation | Anytime |
