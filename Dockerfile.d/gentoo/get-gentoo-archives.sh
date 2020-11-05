#!/bin/sh

GENTOO_ARCH=${GENTOO_ARCH:-amd64}
GENTOO_MIRROR=${GENTOO_MIRROR:-'https://gentoo.osuosl.org/'}
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
WORKING_DIR=${GENTOO_WORKING_DIR:-${SCRIPT_DIR}/working-dir}

# Resolve latest stage3 archive filename.
wget --output-document "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}.txt" "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/latest-stage3-${GENTOO_ARCH}.txt"
grep -vE '^\s*(#|$)' "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}.txt" | awk '{ print $1 }' | tee "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt"
basename $(cat "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt") > "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-filename.txt"

# Download the stage3 archive.
if [ ! -f "${WORKING_DIR}/$(cat ${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-filename.txt)" ]; then
  wget --directory-prefix "${WORKING_DIR}/" "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/$(cat ${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt)"
fi

# Download and extract portage repository archive.
# see also: https://wiki.gentoo.org/wiki//var/db/repos/gentoo
if [ ! -f "${WORKING_DIR}/portage-latest.tar.xz" ]; then
  wget --directory-prefix "${WORKING_DIR}/" "${GENTOO_MIRROR}/snapshots/portage-latest.tar.xz"
fi
