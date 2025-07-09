# K1-Klipper-Eddy

This project is centaur with a body of stock creality K1 series firmware v2.3.5.35 (yeah, it is for CFS) and head in the form of several SimpleAF modules that are required for purposes of BTT Eddy support. The project ports several modules, code portions even configuration files from famous [pellcorp/SimpleAF project](https://pellcorp.github.io/creality-wiki/).

NOTES: The project is still in develop phaze. Everything you are doing, you are doing at your own risk. Printer physical damage is possible. The author is not responsible for any consequences of using this project.

## Goals
The main goal of the project is to allow Creality CFS users to switch from PRTouch v2 to BTT Eddy for faster and more precise automated bed leveling.

However there are some technical goals achieving of that must allow to successfuly adopt the project to upcoming versions of either Creality stock firmware or SimpleAF:
1. Keep as many stock creality modules untouched as possible.
2. Port as few SimpleAF modules without changes as possible.
3. Preserve SimpleAF Eddy MCU compatibility to simplify SimpleAF migration in future when and if it will become CFS compatible.

## Prerequisites
1. Root the printer as shown on [creality-helper-script wiki page](https://guilouz.github.io/Creality-Helper-Script-Wiki/firmwares/install-and-update-rooted-firmware-k1/).
2. The git out of the box in v2.3.5.35 does not work with github.You shoud install functioning git before continue. The simplest way to do that - use entware:
```bash
wget http://bin.entware.net/mipselsf-k3.4/installer/generic.sh -O - | sh
export PATH=/opt/bin:/opt/sbin:$PATH
opkg update
opkg install git-http
opkg install git
mv /usr/bin/git /usr/bin/git.backup
ln -s /opt/bin/git /usr/bin/git
```
3. Mount BTT Eddy to your printer then upload firmware to it according to [SimpleAF instructions](https://pellcorp.github.io/creality-wiki/btteddy/#probe-installation), but do not install SimpleAF itself.

## Installation
1. Log in to K1 with ssh command:
```bash
ssh root@ip-address-of-k1
```
2. Clone K1-Klipper-Eddy sources from github with git command then enter project directory:
```bash
cd /usr/data
git clone https://github.com/vsevolod-volkov/K1-Klipper-Eddy.git
cd K1-Klipper-Eddy
```
3. Run installation script:
```bash
sh ./install.sh
```
4. Copy eddy support files to your klipper configuration directory:
```bash
cd config
cp btteddy.cfg btteddy_macro.cfg /usr/data/printer_data/config
```
5. Add following lines to the beginning of your *printer.cfg* klipper configuration file:
```
[include btteddy.cfg]
[include btteddy_macro.cfg]
```
6. Find and comment out with hash sign those lines in ```[stepper_z]``` section of your *printer.cfg* klipper configuration file:
```
[stepper_z]
...
endstop_pin: tmc2209_stepper_z:virtual_endstop
position_endstop: 0 
...
```
The result will look like that:
```
[stepper_z]
...
# endstop_pin: tmc2209_stepper_z:virtual_endstop
# position_endstop: 0 
...
```

7. Add following line in ```[stepper_z]``` section of your *printer.cfg* klipper configuration file:
```
[stepper_z]
...
endstop_pin: probe:z_virtual_endstop
```
8. Comment out whole ```[prtouch_v2]``` and ```[bed_mesh]``` sections of your *printer.cfg* klipper configuration file with hash sign or delete them at all. Commenting out the ```[mcu leveling_mcu]``` section will allow you to avoid leveling MCU overheating when using high bed temperatures and prevent print emergency stops. Comment it if you do not use it for some purposes. 
9. Type ```ls /dev/serial/by-id/*``` into the printer command line. The found device will be what you enter into your *btteddy.cfg* under ```[mcu eddy]``` for the *serial* variable. 
10. Change Eddy MCU path inside *btteddy.cfg* file:
```
[mcu eddy]
...
serial: /dev/serial/by-id/usb-Klipper_rp2040_xxxxxxxxx
...
```
11.  Depending of [BTT Eddy mount option](https://pellcorp.github.io/creality-wiki/btteddy/#mount-options) you choose, correct *x_offset* and *y_offset* in *btteddy.cfg* under ```[probe_eddy_current btt_eddy]``` section. Defaault values given for "Default" mount option.
22.   Reboot your printer.

## Calibration

Follow the [SimpleAF instruction](https://pellcorp.github.io/creality-wiki/btteddy/#calibration) steps to perform:
- drive current calibration
- nozzle height mapping calibration
- temperature calibration.

**IMPORTANT:** Please pay an attention that stock Creality ```G28 X Y``` implementation does not move carriage to bed center. To avoid that you may move it to center (x=110, y=110 for K1/K1C/K1SE) with fluidd or mainsail. You also need to run ```_SET_KIN_MAX_Z``` macro after ```G28 X Y``` even when proceed with *Mapping Eddy Readings To Nozzle Heights* calibration according to SimpleAF instructions.