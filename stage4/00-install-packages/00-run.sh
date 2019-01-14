#!/bin/bash

install -v -m 644 files/lightdm.conf                     "${ROOTFS_DIR}/etc/lightdm/lightdm.conf"
install -v -m 644 files/autostart                        "${ROOTFS_DIR}/etc/xdg/lxsession/LXDE/autostart"

on_chroot << EOF
sed -ie 's/mount_on_startup=1/mount_on_startup=0/g' /home/pi/.config/pcmanfm/LXDE/pcmanfm.conf
sed -ie 's/mount_removable=1/mount_removable=0/g' /home/pi/.config/pcmanfm/LXDE/pcmanfm.conf
sed -ie 's/autorun=1/autorun=0/g' /home/pi/.config/pcmanfm/LXDE/pcmanfm.conf
EOF

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
