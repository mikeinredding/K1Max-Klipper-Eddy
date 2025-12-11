#!/bin/sh

set -e

function set_paths() {

  # Colors #
  white=`echo -en "\033[m"`
  blue=`echo -en "\033[36m"`
  cyan=`echo -en "\033[1;36m"`
  yellow=`echo -en "\033[1;33m"`
  green=`echo -en "\033[01;32m"`
  darkred=`echo -en "\033[31m"`
  red=`echo -en "\033[01;31m"`

  # System #
  INITD_FOLDER="/etc/init.d"
  USR_DATA="/usr/data"
  USR_SHARE="/usr/share"
  PRINTER_DATA_FOLDER="$USR_DATA/printer_data"

  # Helper Script #
  HELPER_SCRIPT_FOLDER="$(dirname "$(readlink -f /usr/bin/helper)")"
  HS_FILES="${HELPER_SCRIPT_FOLDER}/files"
  HS_CONFIG_FOLDER="$PRINTER_DATA_FOLDER/config/Helper-Script"
  HS_BACKUP_FOLDER="$USR_DATA/helper-script-backup"

  # EDDYHelper Script #
  EHS_FILES="${EDDYHELPER_SCRIPT_FOLDER}/files"
  EHS_CONFIGS="${EDDYHELPER_SCRIPT_FOLDER}/config"
  EHS_PRINTER_DATA_FOLDER="$PRINTER_DATA_FOLDER/config/Eddy-Helper"
  
  # Configuration Files #
  MOONRAKER_CFG="${PRINTER_DATA_FOLDER}/config/moonraker.conf"
  PRINTER_CFG="${PRINTER_DATA_FOLDER}/config/printer.cfg"
  MACROS_CFG="${PRINTER_DATA_FOLDER}/config/gcode_macro.cfg"
  
  # Moonraker #
  MOONRAKER_FOLDER="${USR_DATA}/moonraker"
  MOONRAKER_URL1="${HS_FILES}/moonraker/moonraker.tar.gz"
  MOONRAKER_URL2="${HS_FILES}/moonraker/moonraker.conf"
  MOONRAKER_URL3="${HS_FILES}/moonraker/moonraker.asvc"
  MOONRAKER_SERVICE_URL="${HS_FILES}/services/S56moonraker_service"
  
  # Nginx #
  NGINX_FOLDER="${USR_DATA}/nginx"
  NGINX_URL="${BTTEHS_FILES}/moonraker/nginx.tar.gz"
  NGINX_SERVICE_URL="${BTTEHS_FILES}/services/S50nginx"
  NGINX_CONF_URL="${BTTEHS_FILES}/moonraker/nginx.conf"
  
  # Klipper #
  KLIPPER_EXTRAS_FOLDER="/usr/share/klipper/klippy/extras"
  KLIPPER_CONFIG_FOLDER="${PRINTER_DATA_FOLDER}/config"
  KLIPPER_KLIPPY_FOLDER="/usr/share/klipper/klippy"
  KLIPPER_SERVICE_URL="${HS_FILES}/services/S55klipper_service"
  KLIPPER_GCODE_URL="${HS_FILES}/fixes/gcode.py"
  KLIPPER_GCODE_3V3_URL="${HS_FILES}/fixes/gcode_3v3.py"
  
  # Fluidd #
  FLUIDD_FOLDER="${USR_DATA}/fluidd"
  FLUIDD_URL="https://github.com/fluidd-core/fluidd/releases/latest/download/fluidd.zip"

  # Mainsail #
  MAINSAIL_FOLDER="${USR_DATA}/mainsail"
  MAINSAIL_URL="https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip"
  
  # Klipper Gcode Shell Command #
  KLIPPER_SHELL_FILE="${KLIPPER_EXTRAS_FOLDER}/gcode_shell_command.py"
  KLIPPER_SHELL_URL="${HS_FILES}/gcode-shell-command/gcode_shell_command.py"
  
  # Eddy #
  EDDY_FOLDER="${EHS_PRINTER_DATA_FOLDER}/eddy"
  EDDY_CONFIG="${EDDY_FOLDER}/config"
  EDDY_KLIPPY="${EHS_FILES}/eddy/klippy"
  EDDY_K1_URL="${EHS_CONFIGS}/btteddyk1.cfg"
  EDDY_K1M_URL="${EHS_CONFIGS}/btteddyk1max.cfg"
  EDDY_MCU==$(ls /dev/serial/by-id/* | grep "Klipper_rp204")
  EDDY_KLIPPER_FOLDER="/usr/share/klipper"

 # Cleanup #
  CLEANUP_FILE="${EHS_CONFIGS}/cleanup.cfg"
  CLEANUP_FOLDER="${EHS_PRINTER_DATA_FOLDER}/cleanup"
  CLEANUP_CONFIG_FILE="${CLEANUP_FOLDER}/cleanup.cfg"

 # Screws Tilt Adjust Support #
  SCREWS_ADJUST_FILE="${HS_CONFIG_FOLDER}/screws-tilt-adjust.cfg"
  SCREWS_ADJUST_URL="${EHS_FILES}/screws-tilt-adjust/screws_tilt_adjust.cfg"
  SCREWS_ADJUST_K1_URL="${EHS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1.cfg"
  SCREWS_ADJUST_K1M_URL="${EHS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1max.cfg"


}

function set_permissions() {

  chmod +x "$CURL" >/dev/null 2>&1 &

}