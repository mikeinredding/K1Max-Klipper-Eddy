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

## Flashing from a Windows PC (before mounting it)

The simplest way to flash a new Eddy is on your computer, before it goes on
the printer. No software to install; Windows sees the Eddy as a USB drive.

> **Eddy Duo:** switch it to **USB mode** first.

1. **Download the firmware.** Open [`btteddy-usb.uf2`](btteddy-usb.uf2) on
   GitHub and click **Download raw file** (the download arrow at the top
   right of the file view). Save it somewhere easy, like Downloads.
2. *(Optional)* **Check the download.** In PowerShell, in the folder you
   saved it to:
   ```powershell
   Get-FileHash .\btteddy-usb.uf2 -Algorithm SHA256
   ```
   The hash should match the SHA-256 at the top of this page.
3. **Put the Eddy in boot mode.** With the Eddy unplugged, hold its **BOOT**
   button (next to the cable plug) and plug its USB cable into your PC.
   Release the button after a couple of seconds.
4. **Find the drive.** A new drive called **RPI-RP2** appears in File
   Explorer (it contains `INDEX.HTM` and `INFO_UF2.TXT`). If it doesn't:
   unplug, and try again holding BOOT the whole time you plug in; try a
   different USB port; or try another cable, since some cables only charge
   and carry no data.
5. **Copy the firmware.** Drag `btteddy-usb.uf2` onto the **RPI-RP2** drive.
   The drive disappears on its own within a few seconds: that means the
   Eddy flashed and restarted. Windows may show an error that the copy
   didn't finish or the drive was removed; that's normal here.
6. **Check it (optional).** In **Device Manager** under **Ports (COM &
   LPT)** a new USB serial device appears while the Eddy is plugged in. That
   is the Eddy running Klipper.
7. Unplug the Eddy and mount and connect it to the printer
   ([hardware guide](../docs/EDDY_HARDWARE.md)). Once connected, check over
   SSH that `ls /dev/serial/by-id/` lists `usb-Klipper_rp2040_<serial>-if00`.

You normally only flash once: this firmware isn't expected to need updates.
If the Eddy ever stops working because its firmware got corrupted, you can
re-flash it from the printer without taking it off (below).

## Flashing from the printer (re-flash or recovery)

Use this if the Eddy stops showing up or misbehaves and you suspect its
firmware, or if you'd rather flash it already mounted.

- **Eddy still shows up** in `ls /dev/serial/by-id/` as
  `usb-Klipper_rp2040_...`: use the menu or the bootloader steps below, no
  BOOT button needed.
- **Eddy doesn't show up at all** (firmware corrupted): the Eddy can't be
  rebooted from software, so use the BOOT button method at the end of this
  section. The Eddy menu option 4 detects an Eddy put in boot mode this way.

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
