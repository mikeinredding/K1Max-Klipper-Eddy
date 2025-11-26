#!/bin/sh

set -e

function screws_tilt_adjust_message(){
  top_line
  title 'Screws Tilt Adjust Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Modifys Creality Helper Script Screws Tilt Adjust for Eddy Duo             ${white}│"
  echo -e " │ ${cyan}functionality.                                               ${white}│"
  hr
  bottom_line
}

function modify_screws_tilt_adjust(){
  screws_tilt_adjust_message
  local yn
  while true; do
    install_msg "Modify Screws Tilt Adjust Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
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
                cp -f "$SCREWS_ADJUST_K1_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg

                break;;
              K1MAX|k1max)
                echo -e "${white}"
                echo -e "Info: Linking files..."
                cp -f "$SCREWS_ADJUST_K1M_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg

                break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        else
          echo -e "Shouldn't get this..."
        fi
        if grep -q "include Helper-Script/screws-tilt-adjust" "$PRINTER_CFG" ; then
          echo -e "Info: Screws Tilt Adjust Support configurations are already enabled in printer.cfg file..."
        else
          echo -e "Screws Tilt Adjust needed to be installed by the helper script for this to work properly!"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Screws Tilt Adjust Support has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
