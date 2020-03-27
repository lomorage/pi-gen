#!/bin/bash -e
install -v -m 644 files/interfaces.eth           "${ROOTFS_DIR}/etc/network/interfaces"

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d                                   "${ROOTFS_DIR}/etc/systemd/system/networking.service.d"
install -v -m 644 files/reduce-timeout.conf     "${ROOTFS_DIR}/etc/systemd/system/networking.service.d/"

on_chroot << EOF
systemctl disable hostapd
systemctl disable dnsmasq
EOF

if [ -v WPA_COUNTRY ]; then
	echo "country=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

if [ -v WPA_ESSID ] && [ -v WPA_PASSWORD ]; then
on_chroot <<EOF
wpa_passphrase "${WPA_ESSID}" "${WPA_PASSWORD}" >> "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
fi
