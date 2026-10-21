# *** This version uses the Beta Z offset from BTT. There is the No Beta Z offset branch that uses Vsevolod-volkov's original files and allows for z offset babystepping but I havent had time to test or validate it for awhile.
# K1Max-Klipper-Eddy

This project uses Vsevolod-volkov's work taking moduals from SimpleAF(If you dont have a CFS I'd recomend SimpleAF!) combined with Guilouz's [Creality Helper Script](https://github.com/Guilouz/Creality-Helper-Script) into **one script and one menu**. You no longer need to install the Creality Helper Script separately: everything from it (Moonraker, Mainsail, Entware, macros, etc.) is in the [Install]/[Remove]/... menus, and the Eddy pieces are in a new **[BTT Eddy]** menu. Developed using firmware version 2.3.5.34 on a 2024 K1Max and requires 2.3.5.34 does not work with 2.3.5.33. I included an option for the k1 but have not tested at all so who knows what it will do or if the values are correct. This script only supports the K1 series; for other Creality printers use Guilouz's script.

NOTES: Using this the Eddy will work however other stuff may not like the stock nozzle wipe. For nozzle wipe I used https://www.printables.com/model/1023575-prowiper-for-creality-k1-series works pretty well. REMEMBER everything you are doing, you are doing at your own risk. To paraphase Thanos physical damage is inevitable. If you dont destroy at least 1 build plate give it time. I keep a destroyed buildplate and use it anytime I touch anything to do with the Eddy. The author is not responsible for any consequences of using this project.

# Goals
The main goal of the project is to allow Creality CFS users to easily switch from PRTouch v2 to BTT Eddy for faster and more precise automated bed leveling. The Eddy works but requires lots of recalibration it is not set and forget. I really would suggest SimpleAF with EddyNG and an opensource AMS/CFS/MMU or whatever abberviation works for you but if you are stuck with the CFS you are stuck with the CFS

# Support
I'm not going to ask for Money, a cup of coffee or send you to an affilate page but If you use and like the script please take a second to view, download and like some of my models at creality print https://www.crealitycloud.com/user-profile/3769968157/models I plan on adding some of my other mods there such as a chamber heater.

# Prerequisites installation assumes fresh factory reset for install
1. Firmware must be 2.3.5.34 I have heard from multiple users and there have been several issues raised on 2.3.5.33 that were resolved by updating to 2.3.5.34
2. Root the printer as shown on [creality-helper-script wiki page](https://guilouz.github.io/Creality-Helper-Script-Wiki/firmwares/install-and-update-rooted-firmware-k1/).
3. Mount BTT Eddy to your printer then upload firmware to it according to [SimpleAF instructions](https://pellcorp.github.io/creality-wiki/btteddy/#probe-installation), but do not install SimpleAF itself.**(This install assumes default mount)**
4. Make sure you run a bed mesh for default (with PRTouch) and SAVE_CONFIG before installing Eddy. The installer checks for it and will refuse without it.

# Installation
1. Log in to K1 with ssh:
```bash
ssh root@ip-address-of-k1
```
2. Clone K1Max-Klipper-Eddy from github:
```bash
git clone https://github.com/mikeinredding/K1Max-Klipper-Eddy.git /usr/data/K1Max-Klipper-Eddy
```
3. Run the script (after the first run you can just type `eddyhelper`):
```bash
sh /usr/data/K1Max-Klipper-Eddy/eddyhelper.sh
```
4. From **[Install] Menu** install options 1, 3, 4, 5, 10, 11, 13 (Moonraker and Nginx, Mainsail, Entware, Klipper Gcode Shell Command, Improved Shapers Calibrations, Useful Macros, Screws Tilt Adjust Support). These are the options I have installed; others may work but **option 8 Nozzle Cleaning Fan Control will break Klipper with Eddy**, so the script blocks it once Eddy is installed (and Eddy won't install while it is). KAMP (6) and Save Z-Offset Macros (12) are untested and ask for confirmation.
5. Go to **[BTT Eddy] Menu** (main menu option 8). The top of the menu shows status, and option 7 shows a prerequisites checklist.
6. Choose **1 Install BTT Eddy Duo**. It will:
   - check firmware, the saved default mesh, that printer.cfg/sensorless.cfg are stock, and that the Eddy is on USB (asks which one if there's more than one RP2040)
   - back up printer.cfg, gcode_macro.cfg, sensorless.cfg and every Klipper module it replaces to `/usr/data/eddy-helper-backup`
   - install the Eddy config, disable PRTouch, update homing, add FAKE_HOME
   - switch Screws Tilt Adjust to Eddy probe positions if you installed it
   
   **If you are not using the default mount you will need to edit files!!I'll have to make some documentation on which ones**
7. Calibrate from the Mainsail console:
   1. Run FAKE_HOME
   2. Move head to bed center
   3. Move bottom of eddy 20mm from bed
   4. Run LDC_CALIBRATE_DRIVE_CURRENT CHIP=btt_eddy
   5. SAVE_CONFIG
   6. Run FAKE_HOME
   7. Run PROBE_EDDY_CURRENT_CALIBRATE_AUTO CHIP=btt_eddy and use the GUI and a piece of paper to bring the bed up to the nozzle so there is slight resistance when moving the paper, then accept
   8. SAVE_CONFIG
   9. Home all
   10. Run bedmesh and enjoy the rapid scan!
   11. Perform Temperature Compensation Calibration before using following BTTs instructions https://github.com/bigtreetech/Eddy

## Other [BTT Eddy] menu options
- **2 Remove BTT Eddy Duo**: re-enables PRTouch, restores the stock Klipper modules, and undoes only the Eddy edits to printer.cfg, sensorless.cfg and gcode_macro.cfg (your other edits and saved meshes are kept; Eddy calibration is removed from SAVE_CONFIG). Copies of the files as they were are saved in `/usr/data/eddy-helper-backup/removed-<date>`. If Eddy was installed with an older version of this script there is no backup of the Klipper modules, so those stay; everything else is still undone.
- **3 Re-detect Eddy USB serial**: fixes a wrong or missing `serial:` in eddy.cfg (e.g. after swapping the Eddy).
- **4 Switch Screws Tilt Adjust positions**: toggles between Eddy (probe 23mm left of nozzle) and stock positions.
- **5 / 6 Automated Cleanup**: a delayed gcode that deletes print gcode files and timelapse videos older than 30 days, 2 minutes after boot. Needs Klipper Gcode Shell Command.

## Coming from the separate Creality Helper Script?
Anything you installed with Guilouz's script links to files in `/usr/data/helper-script`, so keep that folder, or remove those options with the old `helper` command and reinstall them from `eddyhelper`. The `helper` command keeps working alongside `eddyhelper`.

# Issues
## 1. Have a problem with the install script? Verify you are running 2.3.5.34 firmware, and if so raise an issue and include a klippy.log
Not joking about the 2.3.5.34 firmwre thats the version of firmware I used when making this and it worked. I've never used 2.3.5.33 so I have not tested it. Multiple people have had issues with .33 that went away as soon as they upgraded to .34. If you are running 2.3.5.34 rais an issue and include a klippy log. Max file size for github web is 25MB so if you log is bigger than that just compress it into a zip file and it should compress to around 10% the size.

# Common Issues and resolutions

## 0. Script installed but something not working right?
First thing verify your firmware if you are running 2.3.5.33 upgrade to 2.3.5.34 and try again. 

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
   The eddy duo uses z offset differently as its the distance from the probe to the plate so trying to adjust while printng something it will give you an error and there is no option to save. There are two options If you are using the included eddy.cfg file and havent replaced it with something else beta z offset is enabled so if while not printing you use mainsail or fluid to adjust the z offset to what you want then from console run Z_OFFSET_APPLY_PROBE folowed by a SAVE_CONFIG klipper will restart and when it comes up it will reapply the z offset.    If you copied a eddy.cfg from elsewhere or this would work if you dont want to deal with the first option for your printer in the start print gcode you can specify the offset by adding 
SET_GCODE_OFFSET Z=-0.6 for example to set it to negative .6mm. You also need to add in your stop and cancel sections set the offset back to 0 by adding SET_GCODE_OFFSET Z=0 

## 3. bed_mesh: Unknown profile \[default\]
   See prerequisite #4: run a bed mesh for default and save config before installing (the installer now checks this). If you did not do this you should be able to cut and paste a bed mesh from another config into your config to proceed. I've added a file bedmesh.txt here in the root with a bed mesh from one of my saved configs. Its for a K1Max so not sure if it would work of freak out for a K1

## 4. Print completes but reports as failed
  Molotiilkin1 reported prints finish but show as failed in klipper with an error reported in the klipper console !! Unknown gcode_macro variable 'prepare'. It occurs when the printer is unloading which may be why I didnt notice it as I modified my gcode to not unload as most of the time I print with the same color so saved me time. Anyways if its occuring for you and you care to fix it. Edit the END_PRINT_NO_M84 macro in the gcode_macro.cfg and either comment out or remove the PRINT_PREPARE_CLEAR
```py
[gcode_macro END_PRINT_NO_M84]
gcode:
  BOX_END
  BOX_END_PRINT
  Qmode_exit
  EXCLUDE_OBJECT_RESET
  PRINT_PREPARE_CLEAR # <- comment it or delete
  M220 S100
  SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=2500
  TURN_OFF_HEATERS
  M107 P1
  M107 P2
  END_PRINT_POINT
  WAIT_TEMP_START
  BOX_GET_FIVE_WAY_STATE
```

Should look like this or delete the line
```py
[gcode_macro END_PRINT_NO_M84]
gcode:
  BOX_END
  BOX_END_PRINT
  Qmode_exit
  EXCLUDE_OBJECT_RESET
  #PRINT_PREPARE_CLEAR 
  M220 S100
  SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=2500
  TURN_OFF_HEATERS
  M107 P1
  M107 P2
  END_PRINT_POINT
  WAIT_TEMP_START
  BOX_GET_FIVE_WAY_STATE
```

# Credits
- [Guilouz](https://github.com/Guilouz) for the [Creality Helper Script](https://github.com/Guilouz/Creality-Helper-Script) (GPL-3.0), which this script includes and builds on
- Vsevolod-Volkov for K1-Klipper-Eddy
- [pellcorp](https://github.com/pellcorp) for SimpleAF
