#
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel
recovery_uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.cpio

RECOVERY_KMOD_TARGETS := \
    usbtouchscreen.ko \
    sensors_class.ko \
    sensors_ssc.ko \
    i2c-hid.ko \

RECOVERY_FIRMWARE_TARGETS := \
    chipone_icnl9951r_fw_boe.bin \
    chipone_icnl9951r_fw_dijin.bin \
    chipone_icnl9951r_fw_hjr.bin \
    chipone_icnl9951r_fw_txd.bin \
    chipone_icnl9951r_fw_xinxian.bin \
    focaltech_ft8203_fw_boe.bin \
    focaltech_ft8203_fw_dsbj.bin \
    himax_hx83102j_fw_lide.bin \
    himax_hx83102j_fw_starry.bin \
    himax_hx83102j_mp_lide.bin \
    himax_hx83102j_mp_starry.bin \
    Jadard_firmware.bin \

INSTALLED_RECOVERY_KMOD_TARGETS := $(RECOVERY_KMOD_TARGETS:%=$(TARGET_RECOVERY_ROOT_OUT)/vendor/lib/modules/%)
$(INSTALLED_RECOVERY_KMOD_TARGETS): $(INSTALLED_KERNEL_TARGET)
	echo -e ${CL_GRN}"Copying kernel modules to recovery"${CL_RST}
	@mkdir -p $(dir $@)
	cp $(@F:%=$(TARGET_OUT_VENDOR)/lib/modules/%) $(TARGET_RECOVERY_ROOT_OUT)/vendor/lib/modules/

INSTALLED_RECOVERY_FIRMWARE_TARGETS := $(RECOVERY_FIRMWARE_TARGETS:%=$(TARGET_RECOVERY_ROOT_OUT)/vendor/firmware/%)
$(INSTALLED_RECOVERY_FIRMWARE_TARGETS): $(INSTALLED_KERNEL_TARGET)
	echo -e ${CL_GRN}"Copying touchscreen firmware to recovery"${CL_RST}
	@mkdir -p $(dir $@)
	cp $(@F:%=$(TARGET_OUT_VENDOR)/firmware/%) $(TARGET_RECOVERY_ROOT_OUT)/vendor/firmware/

$(recovery_uncompressed_ramdisk): $(INSTALLED_RECOVERY_KMOD_TARGETS) $(INSTALLED_RECOVERY_FIRMWARE_TARGETS)
