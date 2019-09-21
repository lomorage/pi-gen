#!/bin/bash -e

install -v -m 755 files/install_node.sh          "${ROOTFS_DIR}/sbin/install_node.sh"

#on_chroot << EOF
#/sbin/install_node.sh
#EOF
