#!/bin/bash

usage() {
        echo "Usage: $0 {wlan|eth}" >&2
        exit 3
}

case "$1" in
        wlan)
                echo "switching to wlan bridge"

                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.wlan /etc/network/interfaces
                sudo systemctl restart networking.service
                sudo systemctl enable hostapd.service
                sudo systemctl restart hostapd.service
                ;;
        eth)
                echo "switching to ethernet bridge"
                sudo systemctl stop hostapd.service
                sudo systemctl disable hostapd.service

                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.eth /etc/network/interfaces
                sudo systemctl restart networking.service
                ;;
        *)
                usage
                ;;
esac
