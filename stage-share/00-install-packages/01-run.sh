#!/bin/bash -e

install -v -m 755 files/afp.conf          "${ROOTFS_DIR}/etc/netatalk/afp.conf"
install -v -m 755 files/smb.conf          "${ROOTFS_DIR}/etc/samba/smb.conf"

on_chroot << EOF
(echo $FIRST_USER_PASS;echo $FIRST_USER_PASS) | sudo smbpasswd -s -a $FIRST_USER_NAME
EOF
