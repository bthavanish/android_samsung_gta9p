# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/samsung/gta9p

DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/overlay

# Init files
PRODUCT_PACKAGES += \
    init.gta9p.rc

# Tablet characteristics
PRODUCT_CHARACTERISTICS := tablet
