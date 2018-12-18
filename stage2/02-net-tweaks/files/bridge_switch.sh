#!/bin/bash

usage() {
        echo "Usage: $0 {wlan|eth}" >&2
        exit 3
}

case "$1" in
        wlan)
                echo "switching to wlan bridge"

                sudo systemctl stop piem
                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.wlan /etc/network/interfaces
                sudo systemctl restart networking.service
                sudo systemctl enable hostapd.service
                sudo systemctl restart hostapd.service
                sudo emulator.py config -i wlan0 -e eth0
                sudo systemctl start piem
                ;;
        eth)
                echo "switching to ethernet bridge"
                sudo systemctl stop piem
                sudo systemctl stop hostapd.service
                sudo systemctl disable hostapd.service

                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.eth /etc/network/interfaces
                sudo systemctl restart networking.service
                sudo emulator.py config -i eth1 -e eth0
                sudo systemctl start piem
                ;;
        *)
                usage
                ;;
esac
