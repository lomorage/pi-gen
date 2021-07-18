#!/bin/bash -e

install -m 644 "${ROOTFS_DIR}/etc/network/interfaces.eth" "${ROOTFS_DIR}/etc/network/interfaces"
install -m 644 files/logo_transparent.png "${ROOTFS_DIR}/usr/share/plymouth/debian-logo.png"
install -m 644 files/spinfinity.script    "${ROOTFS_DIR}/usr/share/plymouth/themes/spinfinity/"
install -m 644 files/spinfinity.plymouth  "${ROOTFS_DIR}/usr/share/plymouth/themes/spinfinity/"

on_chroot << EOF
plymouth-set-default-theme -R spinfinity
EOF
