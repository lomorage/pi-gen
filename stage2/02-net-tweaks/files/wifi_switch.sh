#!/bin/bash
set -e

TIMEOUT_SEC=5
CLIENT_MODE_READY=0

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

switch_ap_mode() {
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
}

wait_client_mode_ready()
{
        WAIT_SEC=0
        DONE=0
        while [ $DONE -eq 0 ];
        do
                IPv4ExternalAddr=$(ip addr list wlan0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1)
                if [ "$IPv4ExternalAddr" == "" ]; then
                        echo "Address not ready, wait for 1 seconds ..."
                        sleep 1
                        WAIT_SEC=$((WAIT_SEC+1));
                else
                        echo "Address ready $IPv4ExternalAddr"
                        CLIENT_MODE_READY=1
                        DONE=1
                fi

                if [ $WAIT_SEC -gt $TIMEOUT_SEC ]; then
                        echo "Timeout, not able to get ipv4 address"
                        DONE=1
                fi
        done
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

                wait_client_mode_ready
                if [ $CLIENT_MODE_READY -eq 1 ]; then
                        echo "switch to client mode succ"
                else
                        switch_ap_mode
                fi
                ;;
        ap)
                echo "wifi switching to AP mode"
                ;;
        *)
                usage
                ;;
esac
