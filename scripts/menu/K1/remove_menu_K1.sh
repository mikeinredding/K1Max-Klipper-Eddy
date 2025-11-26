#!/bin/sh

set -e

function remove_menu_ui_k1() {
  top_line
  title '[ REMOVE MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Remove' 'Moonraker and Nginx'
  menu_option ' 2' 'Remove' 'Fluidd (port 4408)'
  menu_option ' 3' 'Remove' 'Mainsail (port 4409)'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  bottom_line
}

function remove_menu_k1() {
  clear
  remove_menu_ui_k1
  local remove_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" remove_menu_opt
    case "${remove_menu_opt}" in
      1)
        if [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are not installed!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Moonraker is needed to use Guppy Screen, please uninstall it first!"
        else
         run "remove_moonraker_nginx" "remove_menu_ui_k1"
        fi;;
      2)
        if [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Fluidd is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Fluidd.${white}"
          echo
        else
          run "remove_fluidd" "remove_menu_ui_k1"
        fi;;
      3)
        if [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Mainsail is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Mainsail.${white}"
          echo
        else
          run "remove_mainsail" "remove_menu_ui_k1"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  remove_menu_k1
}
