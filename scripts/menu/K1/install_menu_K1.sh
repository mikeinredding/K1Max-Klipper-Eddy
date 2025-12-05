#!/bin/sh
set -e
function install_menu_ui_k1() {
  top_line
  title '[ INSTALL MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Install' 'BTTEddyDuo'
  menu_option ' 2' 'Modify screwtiltadjust'
  menu_option ' 3' 'Install Automated cleanup'

  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  bottom_line
}
function install_menu_k1() {
  clear
  install_menu_ui_k1
  local install_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" install_menu_opt
    case "${install_menu_opt}" in
      1)
        if [ -d "EDDY_FOLDER" ]; then  
          error_msg "EddyDuo already installed!"
        else
          run "install_eddyduo" "install_menu_ui_k1"
        fi;;
      2)
	if [ -f "$SCREWS_ADJUST_FILE" ]; then
	  run "modify_screws_tilt_adjust" "install_menu_ui_k1"
        else
	  error_msg "SCREWTILTADJUST already modified!!"
        fi;;
      3)
        if [ -d "$CLEANUP_FILE" ]; then  
          error_msg "Automated Cleanup already installed!"
        else
          run "install_cleanup" "install_menu_ui_k1"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  install_menu_k1
}
