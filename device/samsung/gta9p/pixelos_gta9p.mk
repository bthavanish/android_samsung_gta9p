# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

# Inherit from sm6375-common
$(call inherit-product, device/samsung/sm6375-common/common.mk)

# Inherit PixelOS product
$(call inherit-product, vendor/pixelos/config/common_full_phone.mk)

# Inherit vendor blobs
$(call inherit-product, vendor/samsung/gta9p/gta9p-vendor.mk)

# Boot animation
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1200

## Device identifier
PRODUCT_NAME := pixelos_gta9p
PRODUCT_DEVICE := gta9p
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-X216B
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung

PRODUCT_SHIPPING_API_LEVEL := 33

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="gta9pxxx-user 15 AP3A.240905.015.A2 X216BXXS9DYJ7 release-keys"

BUILD_FINGERPRINT := samsung/gta9pxxx/gta9p:15/AP3A.240905.015.A2/X216BXXS9DYJ7:user/release-keys
