# Copyright (C) 2023 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

# vendor partition blobs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/sm6375-common/proprietary/vendor,$(TARGET_COPY_OUT_VENDOR))

# system_ext partition blobs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/sm6375-common/proprietary/system_ext,$(TARGET_COPY_OUT_SYSTEM_EXT))

# product partition blobs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/sm6375-common/proprietary/product,$(TARGET_COPY_OUT_PRODUCT))

# root lib64 blobs (if any)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/sm6375-common/proprietary/lib64,$(TARGET_COPY_OUT_VENDOR)/lib64)
