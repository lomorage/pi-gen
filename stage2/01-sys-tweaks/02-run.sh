#!/bin/sh -e

wget https://raw.githubusercontent.com/lomoware/lomo_backend_release/master/install.sh -O files/install_lomo.sh

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/lomo"
install -v -o 1000 -g 1000 -m 755 "files/install_lomo.sh" "${ROOTFS_DIR}/home/pi/lomo/"
