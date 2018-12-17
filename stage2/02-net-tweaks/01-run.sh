#!/bin/bash -e
install -v -m 644 files/interfaces.ap           "${ROOTFS_DIR}/etc/network/interfaces.ap"
install -v -m 644 files/interfaces.client       "${ROOTFS_DIR}/etc/network/interfaces.client"
install -v -m 644 files/interfaces.eth          "${ROOTFS_DIR}/etc/network/interfaces.eth"
install -v -m 644 files/interfaces.eth           "${ROOTFS_DIR}/etc/network/interfaces"

install -v -m 755 files/wifi_switch.sh          "${ROOTFS_DIR}/sbin/wifi_switch.sh"

install -v -m 600 files/hostapd.conf            "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"
install -v -m 600 files/dnsmasq.conf            "${ROOTFS_DIR}/etc/dnsmasq.conf"

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d                                   "${ROOTFS_DIR}/etc/systemd/system/networking.service.d"
install -v -m 644 files/reduce-timeout.conf     "${ROOTFS_DIR}/etc/systemd/system/networking.service.d/"

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

on_chroot << EOF
systemctl disable hostapd
systemctl disable dnsmasq
EOF

if [ -v WPA_COUNTRY ]
then
	echo "country=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

if [ -v WPA_ESSID -a -v WPA_PASSWORD ]
then
on_chroot <<EOF
wpa_passphrase ${WPA_ESSID} ${WPA_PASSWORD} >> "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
fi
