#! /usr/bin/env python
from gpiozero import LED
from signal import pause
import argparse
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pin', '-p', type=int, help='BCM pin number the LED is connected with, default to pin 17', default=17)
    parser.add_argument('--ctrl', '-c', help='action on LED', choices=['on', 'off', 'blink'], required=True)
    parser.add_argument('--inter', '-i', type=int, help='on/off interval in seconds, default 1 second', default=1)

    args = parser.parse_args()
    led = LED(args.pin)
    if args.ctrl == 'on':
        led.on()
        pause()
    elif args.ctrl == 'blink':
        led.blink(on_time=args.inter, off_time=args.inter)
        pause()
    else:
        led.off()

if __name__ == '__main__':
    print(sys.argv)
    main()
