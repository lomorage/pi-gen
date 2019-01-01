#!/bin/bash

usage() {
        echo "Usage: $0 {client [ssid] [password]|ap}" >&2
        exit 3
}

wpa_config() {
        sudo sh -c "cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
EOF"
        sudo sh -c "wpa_passphrase $1 $2 >> /etc/wpa_supplicant/wpa_supplicant.conf"
}

case "$1" in
        client)
                echo "wifi switching to client mode"
                if [ "$#" -ne 3 ]; then
                        usage
                fi
                sudo systemctl stop dnsmasq.service
                sudo systemctl stop hostapd.service
                sudo systemctl disable dnsmasq.service
                sudo systemctl disable hostapd.service

                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.client /etc/network/interfaces
                sudo ip addr flush wlan0
                wpa_config $2 $3
                sudo systemctl enable wpa_supplicant.service
                sudo systemctl restart wpa_supplicant.service
                sudo systemctl restart networking.service
                ;;
        ap)
                echo "wifi switching to AP mode"
                sudo systemctl stop wpa_supplicant.service
                sudo systemctl disable wpa_supplicant.service

                sudo rm /etc/network/interfaces
                sudo ln -sf /etc/network/interfaces.ap /etc/network/interfaces
                sudo ip addr flush wlan0
                sudo systemctl restart networking.service
                sudo systemctl enable dnsmasq.service
                sudo systemctl enable hostapd.service
                sudo systemctl restart dnsmasq.service
                sudo systemctl restart hostapd.service
                ;;
        *)
                usage
                ;;
esac
