#!/bin/sh

GENTOO_ARCH=${GENTOO_ARCH:-amd64}
GENTOO_MIRROR=${GENTOO_MIRROR:-'https://ftp.jaist.ac.jp/pub/Linux/Gentoo/'}
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
CACHE_DIR=${GENTOO_WORKING_DIR:-${SCRIPT_DIR}/cache/${GENTOO_ARCH}}
WORKING_DIR=${GENTOO_WORKING_DIR:-${SCRIPT_DIR}/working-dir}
GENTOO_STAGE3_POINTER_FILENAME=latest-stage3-${GENTOO_ARCH}-openrc.txt

# Download gentoo portage from GitHub
mkdir -p "${CACHE_DIR}/var/db/repos/gentoo/"
wget --no-verbose\
 --output-document=- --output-file=/dev/null https://github.com/gentoo/gentoo/tarball/HEAD\
 | tar xz --strip-components=1 -C "${CACHE_DIR}/var/db/repos/gentoo"

# Resolve latest stage3 archive filename.
wget --no-verbose\
 --output-document "${WORKING_DIR}/${GENTOO_STAGE3_POINTER_FILENAME}"\
 "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/${GENTOO_STAGE3_POINTER_FILENAME}"
grep -vE '^\s*(#|$)' "${WORKING_DIR}/${GENTOO_STAGE3_POINTER_FILENAME}"\
 | awk '{ print $1 }'\
 | tee "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt"
basename $(cat "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt")\
 > "${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-filename.txt"

# Download the stage3 archive.
if [ ! -f "${WORKING_DIR}/$(cat ${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-filename.txt)" ]; then
  # Remove old stage3 archives.
  rm -f ${WORKING_DIR}/stage3-${GENTOO_ARCH}-*.tar.xz
  wget --directory-prefix "${WORKING_DIR}/"\
   --no-verbose\
   "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/$(cat ${WORKING_DIR}/latest-stage3-${GENTOO_ARCH}-path.txt)"
fi
