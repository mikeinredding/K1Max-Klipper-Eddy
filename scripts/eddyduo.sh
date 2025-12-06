#!/bin/sh
set -e

function eddy_message(){
  top_line
  title 'EddyDUo' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Installs Vsevolod-Volkov K1-Klipper-Eddy functionality         ${white}│"
  echo -e " │ ${cyan}using (Guilouz) Creality Helper Script as a framework          ${white}│"
  hr
  bottom_line
}


function install_eddyduo(){
  eddy_message
  local yn
	while true; do 
    	install_msg "Install EddyDuo" yn
		case "${yn}" in
      		Y|y)
        	echo -e "${white}"
        	if [ -f "$EDDY_CFG"]; then
          		rm -f "$EDDY_CFG" 
        	fi
        echo
        	if [ "$model" = "K1" ]; then 
          		local printer_choice
          		while true; do 
            		read -p " ${white}Do you want install it for ${yellow}K1${white} or ${yellow}K1 Max${white}? (${yellow}k1${white}/${yellow}k1max${white}): ${yellow}" printer_choice
            		case "${printer_choice}" in
              			K1|k1)
                			echo -e "${white}"
                			echo -e "Info: Copying file..."
					echo -e "$EDDY_K1_URL"
					echo -e "$EDDY_CONFIG"
                			cp -f "$EDDY_K1_URL" "$EDDY_FOLDER"/eddy.cfg
				 	cp -f "$EDDY_CONFIG/fan_control.cfg" "$EDDY_FOLDER"/fan_control.cfg
				 	rsync --verbose --recursive $EDDY_KLIPPY $EDDY_KLIPPER_FOLDER

               		 	break;;
              			K1MAX|k1max)
                			echo -e "${white}"
                			echo -e "Info: Copying files..."
					mkdir -p "$EDDY_FOLDER"
                			cp -f "$EDDY_K1M_URL" "$EDDY_FOLDER"/eddy.cfg
					cp -f "$EHS_CONFIGS/fan_control.cfg" "$EDDY_FOLDER"/fan_control.cfg
                			rsync --verbose --recursive $EDDY_KLIPPY $EDDY_KLIPPER_FOLDER
                		break;;
              			*)
                			error_msg "Please select a correct choice!";;
					esac
		          done 
        	else
          		echo -e "Shouldn't get this..."
       		fi
        
        if grep -q "include Eddy-Helper/eddy/eddy.cfg" "$PRINTER_CFG" ; then
          echo -e "Info: Eddy configurations are already enabled in printer.cfg file..."
        else
        	echo -e "Info: Adding Eddy configurations in printer.cfg file..."
        	sed -i '/\[include printer_params\.cfg\]/a \[include Eddy-Helper/eddy/eddy\.cfg\]' "$PRINTER_CFG"
	  		sed -i '/\[include printer_params\.cfg\]/a \[include Eddy-Helper/eddy/fan_control\.cfg\]' "$PRINTER_CFG"
			sed -i '/\[mcu leveling_mcu\]/,/restart_method: command/s/^/#/' "$PRINTER_CFG"
	  		sed -i '/endstop_pin: tmc2209_stepper_z:virtual_endstop/s/^[ \t]*[^#]/#&/' "$PRINTER_CFG"
	  		sed -i '/\#endstop_pin: tmc2209_stepper_z:virtual_endstop/a endstop_pin: probe:z_virtual_endstop' "$PRINTER_CFG"
			sed -i '/position_endstop: 0/s/^/#/' "$PRINTER_CFG"
	  		sed -i '/\[prtouch_v2\]/,/\[display_status\]/{ /\[display_status\]/!s/^/#/ }' "$PRINTER_CFG"
	  		#sed -i '/\[prtouch_v2\]/,/\[verify_heater extruder\]/{ /\[verify_heater extruder\]/!s/^/#/ }' "$PRINTER_CFG"
	  		sed -i 's/\bG28\b/G0028/g' "$PRINTER_DATA_FOLDER/config/sensorless.cfg"
	  		sed -i '/^\[mcu\]/i [force_move]\
enable_force_move: True' "$PRINTER_CFG"
			echo -e "Info: Adding Eddy configurations in sensorless.cfg file..."
	  		FILE_PATH="/usr/data/printer_data/config/sensorless.cfg"
	  		TEMP_FILE=$(mktemp)
	  		cat <<'EOF' > "$TEMP_FILE"
[gcode_macro G28]
rename_existing: G0028
gcode:
{% set POSITION_X = printer.configfile.settings['stepper_x'].position_max/2 %}
{% set POSITION_Y = printer.configfile.settings['stepper_y'].position_max/2 %}
G0028 {rawparams}
G90 ; Set to Absolute Positioning
G0 X{POSITION_X} Y{POSITION_Y} F3000 ; Move to bed center
{% if not rawparams or (rawparams and 'Z' in rawparams) %} #added when combineing eddy configfiles
PROBE #added when combineing eddy configfiles
SET_Z_FROM_PROBE #added when combineing eddy configfiles
{% endif %} #added when combineing eddy configfiles
EOF
#DO NOT ADD WHITESPACE OR TABS OR ANYTHING TO THE LINR WITHEOF
	 		sed -i -e '/\[gcode_macro _IF_HOME_Z\]/!b' -e "r $TEMP_FILE" -e 'd' -e 'G' "$FILE_PATH"
	 		rm "$TEMP_FILE"
			echo -e "Info: Adding Eddy configurations in gcode_macro.cfg file..."
	  		FILE_PATH="/usr/data/printer_data/config/gcode_macro.cfg"
	  		TEMP_FILE=$(mktemp)
	  		cat <<'EOF' > "$TEMP_FILE"
[gcode_macro FAKE_HOME]
description: Sets the toolhead position to X=150 Y=150 Z=100 for debugging.
gcode:
# Caution: This command is for debugging only. Do not use it
# during normal operations or printing.
RESPOND MSG="!! Setting kinematic position to X=150 Y=150 Z=100 !!"
SET_KINEMATIC_POSITION X=150 Y=150 Z=100
EOF
		sed -i -e '/\[gcode_macro LOAD_MATERIAL_CLOSE_FAN2\]/ r '"$TEMP_FILE" "$FILE_PATH"
        fi

        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Eddy installed successfully....I hope!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;; # Exit the function if canceled

      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
