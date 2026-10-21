#!/bin/sh

set -e

function screws_tilt_adjust_message(){
  top_line
  title 'Screws Tilt Adjust Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to add support for Screws Tilt Adjust              ${white}│"
  echo -e " │ ${cyan}functionality.                                               ${white}│"
  hr
  bottom_line
}

function install_screws_tilt_adjust(){
  screws_tilt_adjust_message
  local yn
  while true; do
    install_msg "Screws Tilt Adjust Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Backing up original file..."
        if [ ! -d "$HS_BACKUP_FOLDER"/screws-tilt-adjust ]; then
          mkdir -p "$HS_BACKUP_FOLDER"/screws-tilt-adjust
        fi
        if [ -f "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py ]; then
          mv "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py "$HS_BACKUP_FOLDER"/screws-tilt-adjust
          if [ -f "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.pyc ]; then
            mv "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.pyc "$HS_BACKUP_FOLDER"/screws-tilt-adjust
          fi
        fi
        echo
        eddy_choose_printer
        echo -e "Info: Linking files..."
        if eddy_installed; then
          echo -e "Info: BTT Eddy is installed, using Eddy probe positions..."
          if [ "$EDDY_PRINTER" = "k1max" ]; then
            ln -sf "$SCREWS_ADJUST_K1M_EDDY_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
          else
            ln -sf "$SCREWS_ADJUST_K1_EDDY_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
          fi
        elif [ "$EDDY_PRINTER" = "k1max" ]; then
          ln -sf "$SCREWS_ADJUST_K1M_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        else
          ln -sf "$SCREWS_ADJUST_K1_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        fi
        rm -f "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py
        ln -sf "$SCREWS_ADJUST_URL" "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py
        if grep -q "include Helper-Script/screws-tilt-adjust" "$PRINTER_CFG" ; then
          echo -e "Info: Screws Tilt Adjust Support configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Screws Tilt Adjust Support configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/screws-tilt-adjust\.cfg\]' "$PRINTER_CFG"
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

function remove_screws_tilt_adjust(){
  screws_tilt_adjust_message
  local yn
  while true; do
    remove_msg "Screws Tilt Adjust Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoring files..."
        if [ -f "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.py ]; then
          mv "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.py "$KLIPPER_EXTRAS_FOLDER"
          if [ -f "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.pyc ]; then
            mv "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.pyc "$KLIPPER_EXTRAS_FOLDER"
          fi
          rm -rf "$HS_BACKUP_FOLDER"/screws-tilt-adjust
        fi
        if [ ! -n "$(ls -A "$HS_BACKUP_FOLDER")" ]; then
          rm -rf "$HS_BACKUP_FOLDER"
        fi
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        if grep -q "include Helper-Script/screws-tilt-adjust" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Screws Tilt Adjust Support configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/screws-tilt-adjust\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Screws Tilt Adjust Support configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Screws Tilt Adjust Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}