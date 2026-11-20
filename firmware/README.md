# BTT Eddy USB firmware

`btteddy-usb.uf2` is Klipper firmware for the BTT Eddy / Eddy Duo when it is
connected to the printer by **USB**. It is the firmware this project was
developed and tested with.

| | |
|---|---|
| Klipper version | `v0.12.0-425-g69cf71ec7` |
| MCU | RP2040, 12 MHz crystal |
| Connection | USB |
| Bootloader | none (image starts at `0x10000000`, flash with the BOOT button) |
| Includes | LDC1612 (`ldc1612` and `ldc1612_ng`) probe support |
| SHA-256 | `511f1e2dbf366bcb25cc24d93e849351a9bf837bc08e4a69c078611c86d8393e` |

## Flashing from the printer

> **Risky:** a failed flash can brick the Eddy. An **Eddy Duo must be
> switched to USB mode first**; one flashed for CAN at the factory may not
> flash this way.

### Easiest: the Eddy menu

Run `eddyhelper`, open **[BTT Eddy] Menu** and choose **4 Flash Eddy
firmware**. It reboots the Eddy into its bootloader, copies this firmware,
waits for the Eddy to come back, and restarts Klipper if Eddy is installed.

### By hand: via the bootloader (no BOOT button)

This works if the Eddy already runs Klipper firmware, which BTT Eddys usually
do from the factory (and which this firmware is).

1. Find the Eddy's serial device:
   ```bash
   ls /dev/serial/by-id/ | grep Klipper_rp2040
   ```
   If more than one shows up (anything else with an RP2040, like an MMU
   board), work out which one is the Eddy before going on.
2. Reboot it into its bootloader (put your device after `by-id/`):
   ```bash
   /usr/share/klippy-env/bin/python /usr/data/K1Max-Klipper-Eddy/firmware/enter_bootloader.py /dev/serial/by-id/usb-Klipper_rp2040_XXXXXXXX-if00
   ```
3. Wait until the boot drive shows up. This prints a path once it is
   mounted, usually `/tmp/udisk/sda1/INFO_UF2.TXT`:
   ```bash
   ls /tmp/udisk/*/INFO_UF2.TXT
   ```
4. Copy the firmware onto it (change `sda1` if step 3 showed another name):
   ```bash
   cp /usr/data/K1Max-Klipper-Eddy/firmware/btteddy-usb.uf2 /tmp/udisk/sda1/
   sync
   ```
   The Eddy flashes itself and restarts. Run `ls /tmp/udisk/sda1` again: it
   should be gone.
5. Check the Eddy is back: `ls /dev/serial/by-id/` should list
   `usb-Klipper_rp2040_<serial>-if00` again (same name as before).
6. If Eddy is installed, restart Klipper. It shows an Eddy error while the
   Eddy is rebooting, which clears after the restart. Open the **System** tab
   in Mainsail/Fluidd and check the Eddy reports `v0.12.0-425-g69cf71ec7`.

### If the Eddy has no Klipper firmware: BOOT button

Unplug the Eddy, hold the **BOOT** button next to its cable plug, and plug it
back into the printer while holding it. Then continue from step 3 above (or
run menu option 4, which detects an Eddy already in boot mode).

To check the file, compare `sha256sum btteddy-usb.uf2` with the SHA-256 above.

## Credits

The flashing steps, including entering the bootloader without the BOOT
button, are adapted from pellcorp's EddyNG flashing guide for SimpleAF.
`enter_bootloader.py` is copied from Klipper's `scripts/flash_usb.py`
(GPLv3).

## License

Klipper is licensed under the GNU GPLv3. This file is a build of Klipper
version `v0.12.0-425-g69cf71ec7`; source for Klipper is available at
https://github.com/Klipper3d/klipper.
