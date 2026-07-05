# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

# Inherit from sm6375-common vendor
$(call inherit-product, vendor/samsung/sm6375-common/sm6375-common-vendor.mk)

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/gta9p/proprietary/vendor,$(TARGET_COPY_OUT_VENDOR))
