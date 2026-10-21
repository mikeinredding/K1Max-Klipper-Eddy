#!/bin/sh

set -e

function cleanup_message(){
  top_line
  title 'Automated Cleanup' "${yellow}"
  inner_line
  hr
  text_line "A delayed G-code that runs 2 minutes after boot and deletes"
  text_line "print G-code files and timelapse videos older than 30 days."
  text_line "Deleted files are logged to /var/log/creality_cleanup.log."
  hr
  text_line "Review your files before installing and keep copies!" "${darkred}"
  hr
  bottom_line
}

function cleanup_installed() {
  [ -f "$CLEANUP_FILE" ] && return 0
  grep -q "include Eddy-Helper/cleanup/cleanup\.cfg" "$PRINTER_CFG" 2>/dev/null
}

function install_cleanup(){
  cleanup_message
  local yn
  while true; do
    install_msg "Automated Cleanup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Copying file..."
        mkdir -p "$CLEANUP_FOLDER"
        cp -f "$CLEANUP_URL" "$CLEANUP_FILE"
        if grep -q "include Eddy-Helper/cleanup/cleanup\.cfg" "$PRINTER_CFG" ; then
          echo -e "Info: Cleanup configuration is already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Cleanup configuration in printer.cfg file..."
          sed -i '/^\[include printer_params\.cfg\]/a \[include Eddy-Helper/cleanup/cleanup\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Automated Cleanup has been installed successfully!"
        return 0;;
      N|n)
        error_msg "Installation canceled!"
        return 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_cleanup(){
  cleanup_message
  local yn
  while true; do
    remove_msg "Automated Cleanup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -rf "$CLEANUP_FOLDER"
        if grep -q "include Eddy-Helper/cleanup/cleanup\.cfg" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Cleanup configuration in printer.cfg file..."
          sed -i '/include Eddy-Helper\/cleanup\/cleanup\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Cleanup configuration is already removed in printer.cfg file..."
        fi
        if [ -d "$EHS_CONFIG_FOLDER" ] && [ -z "$(ls -A "$EHS_CONFIG_FOLDER")" ]; then
          rm -rf "$EHS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Automated Cleanup has been removed successfully!"
        return 0;;
      N|n)
        error_msg "Deletion canceled!"
        return 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
