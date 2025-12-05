#!/bin/sh
set -e
EDDYHELPER_SCRIPT_FOLDER="$(dirname "$(readlink -f "$0")")"
for script in "${EDDYHELPER_SCRIPT_FOLDER}/scripts/"*.sh; do . "${script}"; done
for script in "${EDDYHELPER_SCRIPT_FOLDER}/scripts/menu/"*.sh; do . "${script}"; done
for script in "${EDDYHELPER_SCRIPT_FOLDER}/scripts/menu/K1/"*.sh; do . "${script}"; done

# function update_eddyhelper_script() {
#  echo -e "${white}"
#  echo -e "Info: Updating EddyCreality Helper Script..."
#  cd "${EDDYHELPER_SCRIPT_FOLDER}"
#  git reset --hard && git pull
#  ok_msg "EDDYCreality Helper Script has been updated!"
#  echo -e "   ${green}Please restart script to load the new version.${white}"
#  echo
#  exit 0
# }

# function eddyupdate_available() {
#  [[ ! -d "${EDDYHELPER_SCRIPT_FOLDER}/.git" ]] && return
#  local remote current
#  cd "${EDDYHELPER_SCRIPT_FOLDER}"
#  ! git branch -a | grep -q "\* main" && return
#  git fetch -q > /dev/null 2>&1
#  remote=$(git rev-parse --short=8 FETCH_HEAD)
#  current=$(git rev-parse --short=8 HEAD)
#  if [[ ${remote} != "${current}" ]]; then
#    echo "true"
#  fi
# }

# function eddyupdate_menu() {
#  local update_available=$(update_available)
#  if [[ "$update_available" == "true" ]]; then
#    top_line
#    title "A new script version is available!" "${green}"
#    inner_line
#    hr
#    echo -e " │ ${cyan}It's recommended to keep script up to date. Updates usually    ${white}│"
#    echo -e " │ ${cyan}contain bug fixes, important changes or new features.          ${white}│"
#    echo -e " │ ${cyan}Please consider updating!                                      ${white}│"
#    hr 
#    echo -e " │ See changelog here: ${yellow}https://tinyurl.com/3sf3bzck               ${white}│"
#    hr
#    bottom_line
#    local yn
#    while true; do
#      read -p " Do you want to update now? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
#      case "${yn}" in
#        Y|y)
#          run "update_eddyhelper_script"
#          if [ ! -x "$EDDYHELPER_SCRIPT_FOLDER"/eddyhelper.sh ]; then
#            chmod +x "$EDDYHELPER_SCRIPT_FOLDER"/eddyhelper.sh >/dev/null 2>&1
#          fi
#          break;;
#        N|n)
#          break;;
#        *)
#          error_msg "Please select a correct choice!";;
#      esac
#    done
#  fi
# }

if [ ! -L /usr/bin/eddyhelper ]; then
  ln -sf "$EDDYHELPER_SCRIPT_FOLDER"/eddyhelper.sh /usr/bin/eddyhelper > /dev/null 2>&1
fi
rm -rf /root/.cache
set_paths
set_permissions
# update_menu
main_menu
