#!/bin/bash -e
install -v -m 644 files/interfaces.wlan         "${ROOTFS_DIR}/etc/network/interfaces.wlan"
install -v -m 644 files/interfaces.eth          "${ROOTFS_DIR}/etc/network/interfaces.eth"
install -v -m 644 files/interfaces.wlan         "${ROOTFS_DIR}/etc/network/interfaces"

install -v -m 755 files/bridge_switch.sh        "${ROOTFS_DIR}/sbin/bridge_switch.sh"
install -v -m 755 files/emulator.py             "${ROOTFS_DIR}/sbin/emulator.py"
install -v -d                                   "${ROOTFS_DIR}/etc/piem"
install -v -m 644 files/piem-config.json        "${ROOTFS_DIR}/etc/piem/config.json"
install -v -m 644 files/piem.service            "${ROOTFS_DIR}/etc/systemd/system/"

install -v -m 600 files/hostapd.conf            "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"

on_chroot << EOF
systemctl enable piem
EOF
