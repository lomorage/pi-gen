#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

install -m 755 files/usbmount           "${ROOTFS_DIR}/usr/share/usbmount/usbmount"
install -m 644 files/usbmount.conf      "${ROOTFS_DIR}/etc/usbmount/"
install -m 644 files/usbmount.rules     "${ROOTFS_DIR}/etc/udev/rules.d/"
install -m 644 files/usbmount@.service  "${ROOTFS_DIR}/etc/systemd/system/"

install -m 644 files/lomo-btn.service     "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/lomo-light@.service  "${ROOTFS_DIR}/etc/systemd/system/"
install -m 755 files/gpio_btn.py          "${ROOTFS_DIR}/sbin/"
install -m 755 files/gpio_light.py        "${ROOTFS_DIR}/sbin/"
install -m 755 files/gpio_light.sh        "${ROOTFS_DIR}/sbin/"

install -m 644 files/lomod.service        "${ROOTFS_DIR}/etc/avahi/services"
install -m 755 files/update-lomod         "${ROOTFS_DIR}/etc/cron.daily/"

on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
systemctl disable ssh
systemctl enable lomo-btn.service
systemctl enable lomo-light@17.service
systemctl enable regenerate_ssh_host_keys
EOF

on_chroot << EOF
rm -rf /media/usb* || true
EOF

on_chroot << EOF
ln -nsf /bin/ntfsfix /sbin/fsck.ntfs
ln -nsf /bin/ntfsfix /sbin/fsck.ntfs-3g
EOF

if [ "${USE_QEMU}" = "1" ]; then
	echo "enter QEMU mode"
	install -m 644 files/90-qemu.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
	on_chroot << EOF
systemctl disable resize2fs_once
EOF
	echo "leaving QEMU mode"
else
	on_chroot << EOF
systemctl enable resize2fs_once
EOF
fi

on_chroot << \EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r "$GRP"
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser pi $GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

on_chroot << EOF
usermod --pass='*' root
EOF

rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*

install -v -m 755 files/install_node.sh          "${ROOTFS_DIR}/sbin/install_node.sh"
on_chroot << EOF
/sbin/install_node.sh
EOF
