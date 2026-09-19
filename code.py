# Button test - Raspberry Pi Pico (RP2040), CircuitPython 9.x / 10.x
#
# Flashes the on-board LED when a fitted tact switch is pressed, so you can
# confirm each switch is soldered to the right pins before closing the case.
#
# Each switch is soldered across a GND + GPIO pair two holes (5.08mm) apart
# and pulls the GPIO to ground when pressed. List the GPIOs you fitted; the
# order here sets the blink count, so the first button blinks once, the
# second twice, and so on. Keep it in step with DEFAULT_BUTTONS in slots.inc.
#
#     GP15  pins 18+20   GP12  pins 18+16   (pins 1-20 edge)
#     GP16  pins 23+21   GP19  pins 23+25   GP20  pins 28+26  (21-40 edge)
#
# Needs nothing beyond the CircuitPython core: no libraries to copy over.

import time

import board
import digitalio
import keypad

BUTTONS = (board.GP15, board.GP16)

led = digitalio.DigitalInOut(board.LED)
led.direction = digitalio.Direction.OUTPUT

# keypad debounces in the background and reports both press and release.
keys = keypad.Keys(BUTTONS, value_when_pressed=False, pull=True)


def blink(n, on=0.08, off=0.12):
    for _ in range(n):
        led.value = True
        time.sleep(on)
        led.value = False
        time.sleep(off)


blink(3, 0.05, 0.05)          # power-on cue: the script is running
print("ready - press a button")

while True:
    event = keys.events.get()
    if event:
        name = str(BUTTONS[event.key_number]).split(".")[-1]
        if event.pressed:
            print(name, "pressed")
            blink(event.key_number + 1)
            led.value = True      # then stay lit while held
        else:
            print(name, "released")
            led.value = False
    time.sleep(0.01)
