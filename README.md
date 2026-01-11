# *** Fork is a work in progress to automate as much as possible the install of files and configuration to allow BTT Eddyduo to work with creality firmware and CFS. I am using the Creality-Helper-Script as a framework to install vsevolod-volkov/K1-Klipper-Eddy who port SimpleAF modules to make it work with Crearlity Firmware. Big thanks for all of the work done by Guilouz, Vsevolad-volkov and the people behind SimpleAF!
# K1Max-Klipper-Eddy

This project uses Vsevolod-volkov's work taking moduals from SimpleAF(If you dont have a CFS I'd recomend SimpleAF!) and uses https://github.com/Guilouz/Creality-Helper-Script as a framework for the install. Developed using firmware version 2.3.5.34 on a 2024 K1Max. I included an option for the k1 but have not tested at all so who knows what it will do or if the values are correct.

NOTES: The project is still in develop phaze. The Eddy will work however other stuff may not like the stock nozzle wipe. Remember everything you are doing, you are doing at your own risk. Printer physical damage is possible. The author is not responsible for any consequences of using this project.

# Goals
The main goal of the project is to allow Creality CFS users to easily switch from PRTouch v2 to BTT Eddy for faster and more precise automated bed leveling.

# Prerequisites installation assumes fresh factory reset for install
1. Root the printer as shown on [creality-helper-script wiki page](https://guilouz.github.io/Creality-Helper-Script-Wiki/firmwares/install-and-update-rooted-firmware-k1/).
2. Install options 1,3,4,5,10,11,13(these are the options I have installed additional options may work but some definalty will cause issues option 8 Nozzel Cleaning fan control for example)
3. Mount BTT Eddy to your printer then upload firmware to it according to [SimpleAF instructions](https://pellcorp.github.io/creality-wiki/btteddy/#probe-installation), but do not install SimpleAF itself.**(This install assumes default mount)**

# Installation
1. Make sure you run a bed mesh for default before proceeding and save config
2. Log in to K1 with ssh command:https://github.com/mikeinredding/K1Max-Klipper-Eddy/tree/main
```bash
ssh root@ip-address-of-k1
```
3. Clone K1MAX-Klipper-Eddy sources from github with git command
```bash
git clone https://github.com/mikeinredding/K1Max-Klipper-Eddy.git /usr/data/K1Max-Klipper-Eddy
```
4. Run installation script:
```bash
sh /usr/data/K1Max-Klipper-Eddy/eddyhelper.sh
```
5. Install options from menu 1 will install EddyDuo automatically identifying the correct device and insert it into the config. 2 Adjusts screw tilt support cordinates for the eddy(tested only on k1max) 3 installs a delayed gcode macro that will clear out timelapse videos and print gcode files older than 30 days.
   **If you are not using the default mount you will need to edit files!!I'll have to make some documentation on which ones**

    5.a if you get a klipper error from command prompt on the printer run ls /dev/serial/by-id/* and copy/paste the device that looks like /dev/serial/by-id/usb-Klipper_rp2040_xxxxxxxxx into the config/Eddy-Hellper/eddy/eddy.cfg and restart klipper. I will look into and fix this it should automatically update.
6. From mainsail console run FAKE_HOME
7. Move head to bed center
8. Move bottom of eddy 20mm from bed
9. From mainsail console run LDC_CALIBRATE_DRIVE_CURRENT CHIP=btt_eddy
10. save config
11. From mainsail console run FAKE_HOME
12. PROBE_EDDY_CURRENT_CALIBRATE_AUTO CHIP=btt_eddy
    use GUI and piece of paper to bring the bed up to the nozzle so that there is slight resistance when moving the paper and accept
13. Save config
14. home all
15. Run bedmesh and enjoy the rapid scan!
16. Perform Temperature Compensation Calibration before using following BTTs instructions https://github.com/bigtreetech/Eddy

# Issues and resolutions
## 1. Print wont start when sent from creality print have to start from mainsail or print starts but filament isnt loaded  
Try updaing your start print gcode for your printer below is mine and a user reported the first 3 lines are what fixed it for them  
G28  
BED_MESH_CALIBRATE  
T[initial_no_support_extruder]  
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer]  
BED_TEMP=[bed_temperature_initial_layer_single]  
M204 S2000  
M104 S[nozzle_temperature_initial_layer]  
G1 Z3 F600  
M83  
G92 E0  
G1 Z1 F600  

## 2. Unable to save z offset
   The eddy duo uses z offset differently as its the distance from the probe to the plate so trying to adjust while printng something it will give you an error and there is no option to save. There are two options If you are using the included eddy.cfg file and havent replaced it with something else beta z offset is enabled so if while not printing you use mainsail or fluid to adjust the z offset to what you want then from console run Z_OFFSET_APPLY_PROBE folowed by a SAVE_CONFIG klipper will      restart and when it comes up it will reaply the z offset. If you copied a eddy.cfg from elsewhere or this would work if you dont want to deal with the first option for your printer in the start print gcode you can specify the offset by adding SET_GCODE_OFFSET Z=-0.6 for example to set it to negative .6mm. You also need to add in your stop and cancel sections set the offset back to 0 by adding SET_GCODE_OFFSET Z=0
