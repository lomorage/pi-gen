#!/bin/bash

install -v -m 644 files/lightdm.conf                     "${ROOTFS_DIR}/etc/lightdm/lightdm.conf"
install -v -m 644 files/autostart                        "${ROOTFS_DIR}/etc/xdg/lxsession/LXDE/autostart"

install -v -d                                            "${ROOTFS_DIR}/home/pi/.config/pcmanfm/LXDE/"
install -v -m 644 files/pcmanfm.conf                     "${ROOTFS_DIR}/home/pi/.config/pcmanfm/LXDE/pcmanfm.conf"

install -v -m 755 files/install_magic_mirror.sh          "${ROOTFS_DIR}/sbin/install_magic_mirror.sh"

on_chroot << EOF
/sbin/install_magic_mirror.sh
EOF

#on_chroot << EOF
## install custom splashscreen.
#THEME_DIR="/usr/share/plymouth/themes/lomorage"
#sudo mkdir $THEME_DIR
#
## splash.png install
## plymouth config install
## plymouth script install
##sudo plymouth-set-default-theme -R lomorage
#EOF
