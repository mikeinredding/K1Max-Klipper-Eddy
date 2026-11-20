# BTT Eddy hardware setup (K1 / K1C / K1 Max)

Do this before running the Eddy install from the **[BTT Eddy]** menu.

> Based on pellcorp's BTT Eddy and EddyNG guides for SimpleAF, with thanks.
> Adapted here for this project's config and the firmware included in this
> repo.

> **Warning:** wrong mount settings or skipping these checks can seriously
> damage your build plate or the Eddy. Keep a spare build plate handy while
> you set it up.

## 1. Print a mount

This project's Eddy config is set up for the **default side mount**: probe
`x_offset: -23.0`, `y_offset: 0` (23 mm left of the nozzle, in line with it
front to back).

| Mount | Printers | Link | Works with this config? |
|---|---|---|---|
| **Default** BTT Eddy mount | K1, K1C, K1 Max | https://www.printables.com/model/1012524-btteddy-creality-k1-k1c-k1-max-mount | Yes |
| Default, Eddy NG variant | K1, K1C, K1 Max | https://www.printables.com/model/1212731-btt-eddy_ng-mount-for-creality-k1-series | Should be, check offsets |
| Pellcorp rear mount v4 | K1, K1C, K1 Max | https://www.printables.com/model/965667-wip-k1-btt-eddy-rear-mount-v4 | No, needs config edits |
| Slam mount | K1C | https://www.printables.com/model/1195575-btt-eddy-mount-for-k1c | No, needs config edits |

Setup helper parts (height gauges): https://www.printables.com/model/1277844-btt-eddy-and-eddy-ng-setup-helpers

**Using any other mount:** before homing, running Screws Tilt Adjust or a
bed mesh, edit `Eddy-Helper/eddy/eddy.cfg`:
- `x_offset` / `y_offset` for where the coil sits relative to the nozzle
- `mesh_min` / `mesh_max` (the comments in the file explain the math)

Then re-check the Screws Tilt Adjust positions too, since the Eddy positions in
this repo assume the default mount. A rear mount (non-zero `y_offset`) also
benefits from axis twist compensation; a side mount with `y_offset: 0` does
not need it.

## 2. Set the height

Mount the Eddy so the **bottom of the coil PCB** (not the bottom of the case)
is about **2.95 mm above the tip of the nozzle**. That height has given the
most reliable results. The setup helper parts above make this easy to check.

## 3. Build plate

Use a **spring steel** build plate on the magnetic sheet. Don't use a plate
with embedded magnets or a non-steel flex plate: the Eddy reads metal, and the
nozzle can dig into those plates.

## 4. Connect it

- **Eddy Duo:** switch it to **USB mode** first. This project only supports
  the USB connection.
- Plug the Eddy into the printer's **front USB port** and run it there for a
  while to make sure it's stable.
- Only after that, if you want a tidier install, wire it directly to the
  mainboard, or make a cable for the lidar port (K1 Max only). Keep the
  original cable intact; you may need it again.

## 5. Flash the firmware

Flash the Eddy with the firmware in this repo from the printer: use
**[BTT Eddy] Menu, option 4**, or the steps in
[firmware/README.md](../firmware/README.md). If the Eddy already runs
Klipper (most do from the factory) no BOOT button is needed.

## 6. Calibration tips

- Do the paper test with **paper**, never a metal feeler gauge: metal under
  the coil throws off the Eddy and can damage it.
- After installing, follow the calibration steps in the main
  [README](../README.md#installation).

## Credits

Mount list, height, cabling and build plate guidance come from **pellcorp's**
BTT Eddy and EddyNG documentation for SimpleAF. Mount designs are by their
respective authors on Printables.
