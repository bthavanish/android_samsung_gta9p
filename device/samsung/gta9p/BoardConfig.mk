# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/samsung/gta9p

include device/samsung/sm6375-common/BoardConfigCommon.mk

# Kernel prebuilt
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

BOARD_NAME                  := SRPWD25B009

# Kernel modules
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
