#!/bin/sh


get_model=$( /usr/bin/get_sn_mac.sh model 2>&1 )
if echo "$get_model" | grep -iq "K1"; then 
  model="K1"
fi

function get_script_version() {
  local version
  cd "${BTTEDDYHELPER_SCRIPT_FOLDER}"
  version="$(git describe HEAD --always --tags | sed 's/-.*//')"
  echo "${cyan}${version}${white}"
}

function version_line() {
  local content="$1"
  local content_length="${#content}"
  local width=$((75))
  local padding_length=$((width - content_length - 3))
  printf " │ %*s%s%s\n" $padding_length '' "$content" " │"
}

function script_title() {
  local title
  if [ "$model" = "K1" ]; then
    title="K1 SERIES"
  else
    title="For K1 Only shouldnt be here"
  fi
  echo "${title}"
}

function main_menu_ui() {
  top_line
  title "• BTTEDDYHELPER SCRIPT K1 by MikeinRedding$(script_title) •" "${blue}"
  title "Based on(Guilouz) Creality Helper Script and Vsevolod-Volkov K1-Klipper-Eddy" "${white}"
  inner_line
  main_menu_option '1' '[Install]' 'Menu'
  main_menu_option '2' '[Remove]' 'Menu not implemented maybe later'
    hr
  inner_line
  hr
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
    bottom_line
}

function main_menu() {
  clear
  main_menu_ui
  local main_menu_opt
  while true; do
    read -p "${white} Type your choice and validate with Enter: ${yellow}" main_menu_opt
    case "${main_menu_opt}" in
      1) clear
         if [ "$model" = "K1" ]; then
           install_menu_k1
         else
           main_menu
         fi
         break;;
      2) clear
         if [ "$model" = "K1" ]; then
           main_menu
         else
           main_menu
         fi
         break;;
      Q|q)
         clear; exit 0;;
      *)
         error_msg "Please select a correct choice!";;
    esac
  done
  main_menu
}
