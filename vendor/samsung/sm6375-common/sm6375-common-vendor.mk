# Copyright (C) 2023 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/samsung/sm6375-common/proprietary/vendor,$(TARGET_COPY_OUT_VENDOR))
