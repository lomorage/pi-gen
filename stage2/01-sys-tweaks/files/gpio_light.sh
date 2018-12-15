#! /bin/bash
set -e

usage() {
    echo "Usage: $0 bcm_pin {blink [interval_sec] | on | off}"
    exit 3
}

led_on_config() {
    local pin=$1
    sudo sh -c "cat << EOF > /etc/lomo-gpio/light-$pin.conf
ARG1=\"-p=$pin\"
ARG2=\"-c=on\"
ARG3=\"-i=1\"
EOF"
}

led_off_config() {
    local pin=$1
    sudo sh -c "cat << EOF > /etc/lomo-gpio/light-$pin.conf
ARG1=\"-p=$pin\"
ARG2=\"-c=off\"
ARG3=\"-i=1\"
EOF"
}

led_blink_config() {
    local pin=$1
    local interval=$2
    sudo sh -c "cat << EOF > /etc/lomo-gpio/light-$pin.conf
ARG1=\"-p=$pin\"
ARG2=\"-c=blink\"
ARG3=\"-i=$interval\"
EOF"
}

if [ "$#" -lt 2 ]; then
    usage
fi

NUM_RE='^[0-9]+$'
if ! [[ $1 =~ $NUM_RE ]]; then
    echo "bcm_pin should be a number"
    usage
fi

if [ ! -d /etc/lomo-gpio ]; then
    sudo mkdir /etc/lomo-gpio
fi

case "$2" in
    blink)
        echo "blink LED on bcm pin $1"
        if [ "$#" -eq 3 ]; then
            if ! [[ $3 =~ $NUM_RE ]]; then
                echo "blink interval should be a number"
                usage
            fi
            led_blink_config $1 $3
        else
            led_blink_config $1 1
        fi
        sudo systemctl stop lomo-light@$1.service
        sudo systemctl start lomo-light@$1.service
        ;;
    on)
        echo "turn on LED on bcm pin $1"
        led_on_config $1
        sudo systemctl stop lomo-light@$1.service
        sudo systemctl start lomo-light@$1.service
        ;;
    off)
        echo "turn off LED on bcm pin $1"
        led_off_config $1
        sudo systemctl stop lomo-light@$1.service
        sudo systemctl start lomo-light@$1.service
        if [ -f /etc/lomo-gpio/light-$1.conf ]; then
            sudo rm /etc/lomo-gpio/light-$1.conf
        fi
        ;;
    *)
        usage
        ;;
esac
