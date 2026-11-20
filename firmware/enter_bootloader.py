#!/usr/bin/env python3
# Put an RP2040 running Klipper (e.g. a BTT Eddy) into its USB bootloader
# without pressing the BOOT button, using Klipper's "1200 baud touch".
#
# Usage: enter_bootloader.py /dev/serial/by-id/usb-Klipper_rp2040_...
#
# The enter_bootloader() function is copied from Klipper's
# scripts/flash_usb.py (Copyright (C) 2019 Kevin O'Connor
# <kevin@koconnor.net>), licensed under the GNU GPLv3.
import sys, fcntl, termios, struct

def set_dtr(fd, on):
    # Best effort, like Klipper: the USB serial port supports DTR, but if
    # the ioctl is refused, the 1200 baud change alone may still work.
    try:
        req = termios.TIOCMBIS if on else termios.TIOCMBIC
        fcntl.ioctl(fd, req, struct.pack('I', termios.TIOCM_DTR))
    except (IOError, OSError):
        pass

def enter_bootloader(device):
    f = open(device, 'rb')
    fd = f.fileno()
    set_dtr(fd, True)
    t = termios.tcgetattr(fd)
    t[4] = t[5] = termios.B1200
    sys.stderr.write("Entering bootloader on %s\n" % (device,))
    termios.tcsetattr(fd, termios.TCSANOW, t)
    set_dtr(fd, False)
    f.close()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: %s <serial device>\n" % (sys.argv[0],))
        sys.exit(2)
    try:
        enter_bootloader(sys.argv[1])
    except (IOError, OSError, termios.error) as e:
        sys.stderr.write("Could not enter bootloader: %s\n" % (e,))
        sys.exit(1)
