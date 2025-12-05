#!/bin/sh

set -e
function cleanup_message(){
  top_line
  title 'Cleanup' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This is an delayed GCode to cleanup videos and gcodes older    ${white}│"
  echo -e " │ ${cyan}than 30 days. 2 minutes after boot any print gcodes and        ${white}│"
  echo -e " │ ${cyan}timelapse videos older than 30 days will be deleted.           ${white}│"
  echo -e " │ ${cyan}Review files before installing and make sure you have copies!  ${white}│"
  hr
  bottom_line
}

function install_cleanup(){
  cleanup_message
  local yn
  while true; do
    install_msg "Cleanup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "CLEANUP_FILE" ]; then
          rm -f "CLEANUP_FILE"
        fi
	mkdir -p "$CLEANUP_FOLDER"
	cp -f "$CLEANUP_FILE" "$CLEANUP_CONFIG_FILE"
        if grep -q "include eddyhelper/cleanup" "$PRINTER_CFG" ; then
          echo -e "Info: Cleanup configuration are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Cleanup configuration in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Eddy-Helper/cleanup/cleanup\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Cleanup installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_cleanup(){
  cleanup_message
  local yn
  while true; do
    remove_msg "Cleanup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -f "CLEANUP_FILE"
        if grep -q "include cleanup" "$PRINTER_CFG" ; then
          echo -e "Info: Removing cleanup configuration in printer.cfg file..."
          sed -i '/include cleanup\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: cleanup configuration are already removed in printer.cfg file..."
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Nozzle Cleaning Fan Control has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}