#! /usr/bin/env python
from gpiozero import Button
from signal import pause
import time
import os
import argparse

millis = lambda: int(round(time.time() * 1000))

BTN_CLICK_CNT = 0
BTN_HELD_CNT = 0
CLICK_CMD = ''
PRESS_CMD = ''

class ButtonEvtHandler(object):
    INIT  = 0
    PRESS = 1
    HOLD  = 2

    def __init__(self, bcm_pin, cb_clicked, cb_held=None, hold_time=3, debounce_delay=300):
        self.btn = Button(bcm_pin)
        self.debounce_delay = debounce_delay
        self.hold_time = hold_time * 1000
        self.btn_st = ButtonEvtHandler.INIT
        self.cb_clicked = cb_clicked
        self.cb_held = cb_held
        self.last_clicked_time = 0
        self.pressed_time = 0
        self.btn.when_pressed = self._on_pressed
        self.btn.when_released = self._on_released
        if cb_held is not None:
            self.btn.when_held = self._on_held
            self.btn.hold_time = hold_time

    def _on_pressed(self):
        #print("pressed")
        self.btn_st = ButtonEvtHandler.PRESS
        self.pressed_time = millis()

    def _on_released(self):
        #print("released")
        current_millis = millis()
        debounce_interval = current_millis - self.last_clicked_time
        if debounce_interval > self.debounce_delay:
            self.last_clicked_time = current_millis
            held_time = current_millis - self.pressed_time
            #print("held_time = %d, threshold = %d" % (held_time, self.hold_time))
            if self.btn_st != ButtonEvtHandler.HOLD:
                if held_time < self.hold_time:
                       self.cb_clicked()
                elif self.cb_held is not None:
                    self.cb_held()
            self.btn_st = ButtonEvtHandler.INIT

    def _on_held(self):
        #print("hold")
        current_millis = millis()
        debounce_interval = current_millis - self.last_clicked_time
        if debounce_interval > self.debounce_delay:
            if self.btn_st == ButtonEvtHandler.PRESS:
                self.btn_st = ButtonEvtHandler.HOLD
                self.cb_held()

def button_clicked():
    global BTN_CLICK_CNT
    BTN_CLICK_CNT += 1
    print(">>>[%03d] Button clicked" % BTN_CLICK_CNT)
    os.system(CLICK_CMD)

def button_held():
    global BTN_HELD_CNT
    BTN_HELD_CNT += 1
    print(">>>[%03d] Button held" % BTN_HELD_CNT)
    os.system(PRESS_CMD)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pin', '-p', type=int, help='BCM pin number the button is connected with, default to pin 3', default=3)
    parser.add_argument('--click', '-c', help='click action command', default='echo "Button clicked"')
    parser.add_argument('--held', '-l', help='long press action command', default='echo "Button held"')
    parser.add_argument('--hold_time', type=int, help='hold time in seconds before trigger long press event, default to 5 seconds', default=5)
    parser.add_argument('--debounce_delay', type=int, help='will ignore click events less than debounce time in milliseconds, default to 300 ms', default=300)
    args = parser.parse_args()

    global CLICK_CMD, PRESS_CMD
    CLICK_CMD = args.click
    PRESS_CMD = args.held
    print("click command: %s" % CLICK_CMD)
    print("long press command: %s" % PRESS_CMD)

    btn_handler = ButtonEvtHandler(args.pin, button_clicked, button_held, args.hold_time, args.debounce_delay)
    pause()

if __name__ == '__main__':
    main()
