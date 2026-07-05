#!/bin/bash
#
# Copyright (C) 2024 The PixelOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# Check for extract-utils in this repo first, then fall back to Android root
if [ -f "${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh" ]; then
    HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
elif [ -f "${MY_DIR}/../../../tools/extract-utils/extract_utils.sh" ]; then
    HELPER="${MY_DIR}/../../../tools/extract-utils/extract_utils.sh"
else
    echo "Unable to find extract_utils.sh"
    echo "Please clone extract-utils first:"
    echo "  git clone https://github.com/LineageOS/android_tools_extract-utils.git tools/extract-utils"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for device
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

# Warning headers and guards
write_headers

# The standard device blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers
