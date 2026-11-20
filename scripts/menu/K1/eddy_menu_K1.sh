#!/bin/sh

set -e

function eddy_check() {
  # $1 = command to test; prints a green tick or red cross
  if "$@"; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function eddy_usb_present() {
  [ -n "$(eddy_usb_devices)" ]
}

function shell_command_present() {
  [ -f "$KLIPPER_SHELL_FILE" ] || [ -L "$KLIPPER_SHELL_FILE" ]
}

function screws_installed() {
  [ -e "$SCREWS_ADJUST_FILE" ] || [ -L "$SCREWS_ADJUST_FILE" ]
}

function web_console_present() {
  [ -d "$MOONRAKER_FOLDER" ] && { [ -d "$MAINSAIL_FOLDER" ] || [ -d "$FLUIDD_FOLDER" ]; }
}

function eddy_menu_ui_k1() {
  local fw
  fw="$(eddy_fw_version)"
  top_line
  title '[ BTT EDDY MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•STATUS:'
  info_line "$(eddy_check eddy_installed)" 'BTT Eddy Duo installed'
  info_line "$(eddy_check eddy_usb_present)" 'Eddy connected on USB'
  info_line "$(eddy_check eddy_fw_ok)" "Firmware ${EDDY_TESTED_FW} (found: ${fw:-unknown})"
  info_line "$(eddy_check eddy_screws_using_eddy)" 'Screws Tilt Adjust uses Eddy positions'
  info_line "$(eddy_check cleanup_installed)" 'Automated Cleanup installed'
  hr
  subtitle '•BTT EDDY DUO:'
  menu_option '1' 'Install' 'BTT Eddy Duo'
  menu_option '2' 'Remove' 'BTT Eddy Duo'
  menu_option '3' 'Re-detect' 'Eddy USB serial'
  hr
  subtitle '•EXTRAS:'
  menu_option '4' 'Switch' 'Screws Tilt Adjust positions (Eddy/stock)'
  menu_option '5' 'Install' 'Automated Cleanup'
  menu_option '6' 'Remove' 'Automated Cleanup'
  hr
  subtitle '•HELP:'
  menu_option '7' 'Check' 'Prerequisites'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  bottom_line
}

function eddy_prerequisites_k1() {
  top_line
  title '[ EDDY PREREQUISITES ]' "${yellow}"
  inner_line
  hr
  subtitle '•REQUIRED BEFORE INSTALL:'
  info_line "$(eddy_check eddy_fw_ok)" "Firmware ${EDDY_TESTED_FW}"
  info_line "$(eddy_check eddy_usb_present)" 'Eddy flashed and connected on USB'
  info_line "$(eddy_check eddy_has_saved_mesh)" "Saved 'default' bed mesh in printer.cfg"
  info_line "$(eddy_check web_console_present)" 'Moonraker + Mainsail/Fluidd (Install 1, 3)'
  hr
  subtitle '•RECOMMENDED (Install menu):'
  info_line "$(eddy_check test -f "$ENTWARE_FILE")" 'Entware (4)'
  info_line "$(eddy_check shell_command_present)" 'Klipper Gcode Shell Command (5)'
  info_line "$(eddy_check test -d "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations (10)'
  info_line "$(eddy_check test -f "$USEFUL_MACROS_FILE")" 'Useful Macros (11)'
  info_line "$(eddy_check screws_installed)" 'Screws Tilt Adjust Support (13)'
  hr
  subtitle '•MUST NOT BE INSTALLED:'
  if nozzle_cleaning_installed; then
    info_line "${red}✗" 'Nozzle Cleaning Fan Control (8) - remove it'
  else
    info_line "${green}✓" 'Nozzle Cleaning Fan Control (8)'
  fi
  hr
  bottom_line
  read -p " ${white}Press Enter to go back to the Eddy menu... " _
}

function eddy_menu_k1() {
  clear
  eddy_menu_ui_k1
  local eddy_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" eddy_menu_opt
    case "${eddy_menu_opt}" in
      1)
        if eddy_installed; then
          error_msg "BTT Eddy Duo is already installed!"
        else
          run "install_eddy" "eddy_menu_ui_k1"
        fi;;
      2)
        if ! eddy_installed; then
          error_msg "BTT Eddy Duo is not installed!"
        else
          run "remove_eddy" "eddy_menu_ui_k1"
        fi;;
      3)
        if ! eddy_installed; then
          error_msg "BTT Eddy Duo is not installed!"
        else
          run "redetect_eddy_serial" "eddy_menu_ui_k1"
        fi;;
      4)
        if ! screws_installed; then
          error_msg "Screws Tilt Adjust Support is not installed!"
          echo -e " ${darkred}Install it first from the [Install] Menu (option 13).${white}"
          echo
        else
          run "toggle_eddy_screws_tilt" "eddy_menu_ui_k1"
        fi;;
      5)
        if cleanup_installed; then
          error_msg "Automated Cleanup is already installed!"
        elif ! shell_command_present; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_cleanup" "eddy_menu_ui_k1"
        fi;;
      6)
        if ! cleanup_installed; then
          error_msg "Automated Cleanup is not installed!"
        else
          run "remove_cleanup" "eddy_menu_ui_k1"
        fi;;
      7)
        clear
        eddy_prerequisites_k1
        break;;
      B|b)
        clear; main_menu; break;;
      Q|q)
        clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  eddy_menu_k1
}
