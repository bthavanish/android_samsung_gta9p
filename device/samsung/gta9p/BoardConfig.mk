# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/samsung/gta9p

include device/samsung/sm6375-common/BoardConfigCommon.mk

# Kernel build mode
# Set to true to build kernel from source, false to use prebuilts
TARGET_KERNEL_BUILD_FROM_SOURCE ?= false

ifeq ($(TARGET_KERNEL_BUILD_FROM_SOURCE),true)
# Source-built kernel
TARGET_KERNEL_SOURCE := kernel/samsung/sm6375
KERNEL_DEFCONFIG := gki_defconfig
KERNEL_DEFCONFIG_FRAGMENTS := \
    kernel/samsung/sm6375/arch/arm64/configs/vendor/holi-qgki_defconfig \
    kernel/samsung/sm6375/arch/arm64/configs/vendor/holi_QGKI.config \
    kernel/samsung/sm6375/arch/arm64/configs/vendor/samsung/gta9p.config
else
# Prebuilt kernel (default)
TARGET_PREBUILT_KERNEL := kernel/samsung/sm6375/prebuilt/Image
endif

# DTB/DTBO (always from prebuilt for now)
BOARD_PREBUILT_DTBIMAGE_DIR := kernel/samsung/sm6375/prebuilt
BOARD_PREBUILT_DTBOIMAGE := kernel/samsung/sm6375/prebuilt/dtbo.img

BOARD_NAME                  := SRPWD25B009

# Kernel modules
BOARD_VENDOR_KERNEL_MODULES := \
    $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules.load))

# Recovery
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt

# Display
TARGET_SCREEN_DENSITY := 450

# OTA assert
TARGET_OTA_ASSERT_DEVICE := gta9p

# Security patch
VENDOR_SECURITY_PATCH := 2025-10-01

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
