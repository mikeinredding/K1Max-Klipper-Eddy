#!/bin/sh

set -e

function eddy_message(){
  top_line
  title 'EddyDUo' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Installs Vsevolod-Volkov K1-Klipper-Eddy${white}│"
  echo -e " │ ${cyan}functionality using (Guilouz) Creality Helper Script as a framework${white}│"
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
        if [ -f "$EDDYHS_CONFIG_FOLDER"/eddy/btteddy.cfg ]; then
          rm -f "$EDDYHS_CONFIG_FOLDER"/eddy/btteddy.cfg 
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
                cp -f "$EDDY_K1_URL" "$EDDY_FOLDER"/eddy.cfg
		cp -f "$EDDY_CONFIG/fan_control.cfg" "$EDDY_FOLDER"/fan_control.cfg
		rsync --verbose --recursive ./files/eddy/klippy/ /usr/share/klipper/klippy/
                break;;
              K1MAX|k1max)
                echo -e "${white}"
                echo -e "Info: Copying files..."
                cp -f "$BTTEDDY_K1M_URL" "$EDDY_FOLDER"/eddy.cfg
		cp -f "$EDDY_CONFIG/fan_control.cfg" "$EDDY_FOLDER"/fan_control.cfg
                rsync --verbose --recursive ./files/eddy/klippy/ /usr/share/klipper/klippy/
                break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        else
          echo -e "Shouldn't get this..."
        fi
        if grep -q "include eddyhelper/eddy/eddy.cfg" "$PRINTER_CFG" ; then
          echo -e "Info: Eddy configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Eddy configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include eddyhelper/eddy/eddy\.cfg\]' "$PRINTER_CFG"
	  sed -i '/\[include printer_params\.cfg\]/a \[include eddyhelper/eddy/fan_control\.cfg\]' "$PRINTER_CFG"
	  sed -i '/endstop_pin: tmc2209_stepper_z:virtual_endstop/s/^[ \t]*[^#]/#&/' "$PRINTER_CFG"
	  sed -i '/\#endstop_pin: tmc2209_stepper_z:virtual_endstop/a endstop_pin: probe:z_virtual_endstop' "$PRINTER_CFG"
	  sed -i '/\[prtouch_v2\]/,/\[display_status\]/{ /\[display_status\]/!s/^/#/ }' "$PRINTER_CFG"
	  sed -i '/\[prtouch_v2\]/,/\[verify_heater extruder\]/{ /\[verify_heater extruder\]/!s/^/#/ }' "$PRINTER_CFG"
	  sed -i 's/\bG28\b/G0028/g' "$PRINTER_DATA_FOLDER/sensorless.cfg"
	  sed -i '/^\[mcu\]/i [force_move]\
	  enable_force_move: True' "$PRINTER_CFG"
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
	 sed -i -e '/\[gcode_macro _IF_HOME_Z\]/!b' -e "r $TEMP_FILE" -e 'd' -e 'G' "$FILE_PATH"
	 rm "$TEMP_FILE"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "BTTEddy installed successfully....I hope!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
