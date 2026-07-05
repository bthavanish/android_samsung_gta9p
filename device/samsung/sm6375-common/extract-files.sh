#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
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

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/lib64/hw/android.hardware.health@2.0-impl-2.1-samsung.so)
            # Replace libutils with vndk30 libutils
            "${PATCHELF}" --replace-needed libutils.so libutils-v30.so "${2}"
            ;;
        vendor/lib64/libsec-ril.so)
            sed -i 's/ril.dds.call.slotid/vendor.calls.slotid/g' "${2}"
            ;;
        vendor/lib64/libsec-ril-dsds.so)
            sed -i 's/ril.dds.call.slotid/vendor.calls.slotid/g' "${2}"
            ;;
    esac
}

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
