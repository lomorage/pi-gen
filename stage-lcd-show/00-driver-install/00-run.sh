#!/bin/bash -e

install -v -m 755 files/install_lcd_driver.sh          "${ROOTFS_DIR}/sbin/install_lcd_driver.sh"
on_chroot << EOF
/sbin/install_lcd_driver.sh
EOF
