#!/usr/bin/env bash
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0

set -e

export DEVICE=sm6375-common
export VENDOR=samsung

export DEVICE_BRAND=samsung
export DEVICE_MODEL=SM-X216B

./../../tools/extract-utils/setup_makefiles.py "$@"
