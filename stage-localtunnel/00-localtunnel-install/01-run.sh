#!/bin/bash -e

install -v -m 755 files/node-install                    "${ROOTFS_DIR}/sbin/node-install"
install -v -m 755 files/localtunnel_install.sh          "${ROOTFS_DIR}/sbin/localtunnel_install.sh"
sed -i "s/FIRST_USER_NAME/$FIRST_USER_NAME/g"           "${ROOTFS_DIR}/sbin/localtunnel_install.sh"

install -v -m 755 files/localtunnel.sh                  "${ROOTFS_DIR}/sbin/localtunnel.sh"
