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

Run these over SSH on the K1, after cloning this repo to
`/usr/data/K1Max-Klipper-Eddy`. Nothing needs to be downloaded: the
firmware is already in the repo.

1. Unplug the Eddy's USB cable from the printer.
2. Hold the **BOOT** button next to the Eddy's cable plug and plug the cable
   back into the printer while still holding it. Release after a few seconds.
3. Find the Eddy's boot drive. The printer mounts it under `/tmp/udisk/`,
   usually as `sda1`:
   ```bash
   ls /tmp/udisk/*/INFO_UF2.TXT
   ```
   The folder that has `INFO_UF2.TXT` is the Eddy. If nothing shows up,
   unplug and repeat step 2. If you have a USB stick in the printer, the
   Eddy may be `sdb1` instead.
4. Copy the firmware onto it (change `sda1` if step 3 showed another name):
   ```bash
   cp /usr/data/K1Max-Klipper-Eddy/firmware/btteddy-usb.uf2 /tmp/udisk/sda1/
   sync
   ```
   The Eddy flashes itself and restarts, and the boot drive disappears.
5. Check the Eddy is back as a Klipper device:
   ```bash
   ls /dev/serial/by-id/
   ```
   You should see `usb-Klipper_rp2040_<serial>-if00`. If you have `lsusb`,
   it shows `1d50:614e` for the Eddy running Klipper (`2e8a:0003` means it is
   still in boot mode and the flash did not happen).
6. If Eddy was already installed, restart Klipper. It shows an Eddy error
   while the Eddy is in boot mode, and that clears after the restart. Open
   the **System** tab in Mainsail/Fluidd and check the Eddy reports
   `v0.12.0-425-g69cf71ec7`.

To check the file, compare `sha256sum btteddy-usb.uf2` with the SHA-256 above.

## License

Klipper is licensed under the GNU GPLv3. This file is a build of Klipper
version `v0.12.0-425-g69cf71ec7`; source for Klipper is available at
https://github.com/Klipper3d/klipper.
