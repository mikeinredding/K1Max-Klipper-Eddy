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

## Flashing

1. Unplug the Eddy's USB cable.
2. Hold the **BOOT** button on the Eddy and plug the USB cable into a computer.
   Release the button once a drive named **RPI-RP2** appears.
3. Copy `btteddy-usb.uf2` onto the RPI-RP2 drive. The drive disappears when
   flashing is done and the Eddy restarts.
4. Plug the Eddy into the printer and check it shows up (over SSH):
   ```bash
   ls /dev/serial/by-id/
   ```
   You should see `usb-Klipper_rp2040_<serial>-if00`. The Eddy Helper install
   finds this automatically.

To check the file you downloaded, compare `sha256sum btteddy-usb.uf2` with the
SHA-256 above.

## License

Klipper is licensed under the GNU GPLv3. This file is a build of Klipper
version `v0.12.0-425-g69cf71ec7`; source for Klipper is available at
https://github.com/Klipper3d/klipper.
