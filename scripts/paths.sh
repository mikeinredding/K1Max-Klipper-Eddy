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

  # BTTEDDYHelper Script #
  BTTEHS_FILES="${BTTEDDYHELPER_SCRIPT_FOLDER}/files"
  HS_CONFIG_FOLDER="$PRINTER_DATA_FOLDER/config/Helper-Script"
  
  # Configuration Files #
  MOONRAKER_CFG="${PRINTER_DATA_FOLDER}/config/moonraker.conf"
  PRINTER_CFG="${PRINTER_DATA_FOLDER}/config/printer.cfg"
  MACROS_CFG="${PRINTER_DATA_FOLDER}/config/gcode_macro.cfg"
  
  # Moonraker #
  MOONRAKER_FOLDER="${USR_DATA}/moonraker"
  MOONRAKER_URL1="${BTTEHS_FILES}/moonraker/moonraker.tar.gz"
  MOONRAKER_URL2="${BTTEHS_FILES}/moonraker/moonraker.conf"
  MOONRAKER_URL3="${BTTEHS_FILES}/moonraker/moonraker.asvc"
  MOONRAKER_SERVICE_URL="${BTTEHS_FILES}/services/S56moonraker_service"
  
  # Nginx #
  NGINX_FOLDER="${USR_DATA}/nginx"
  NGINX_URL="${BTTEHS_FILES}/moonraker/nginx.tar.gz"
  NGINX_SERVICE_URL="${BTTEHS_FILES}/services/S50nginx"
  NGINX_CONF_URL="${BTTEHS_FILES}/moonraker/nginx.conf"
  
  # Klipper #
  KLIPPER_EXTRAS_FOLDER="/usr/share/klipper/klippy/extras"
  KLIPPER_CONFIG_FOLDER="${PRINTER_DATA_FOLDER}/config"
  KLIPPER_KLIPPY_FOLDER="/usr/share/klipper/klippy"
  KLIPPER_SERVICE_URL="${BTTEHS_FILES}/services/S55klipper_service"
  KLIPPER_GCODE_URL="${BTTEHS_FILES}/fixes/gcode.py"
  KLIPPER_GCODE_3V3_URL="${BTTEHS_FILES}/fixes/gcode_3v3.py"
  
  # Fluidd #
  FLUIDD_FOLDER="${USR_DATA}/fluidd"
  FLUIDD_URL="https://github.com/fluidd-core/fluidd/releases/latest/download/fluidd.zip"

  # Mainsail #
  MAINSAIL_FOLDER="${USR_DATA}/mainsail"
  MAINSAIL_URL="https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip"
  
  # Klipper Gcode Shell Command #
  KLIPPER_SHELL_FILE="${KLIPPER_EXTRAS_FOLDER}/gcode_shell_command.py"
  KLIPPER_SHELL_URL="${BTTEHS_FILES}/gcode-shell-command/gcode_shell_command.py"
  
  # Screws Tilt Adjust Support #
  SCREWS_ADJUST_FILE="${BTTEHS_CONFIG_FOLDER}/screws-tilt-adjust.cfg"
  SCREWS_ADJUST_URL="${BTTEHS_FILES}/screws-tilt-adjust/screws_tilt_adjust.py"
  SCREWS_ADJUST_K1_URL="${BTTEHS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1.cfg"
  SCREWS_ADJUST_K1M_URL="${BTTEHS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1max.cfg"

  # Cleanup #
  CLEANUP_FILE="${PRINTER_DATA_FOLDER}/cleanup.cfg"
  CLEANUP_CONFIG_FILE="${BTTEHS_FILES}/cleanup/cleanup.cfg"

  # BttEddyDuo #
  BTTEDDY_FOLDER="${PRINTER_DATA_FOLDER}/config/btteddyduo"
  BTTEDDY_K1_URL="${BTTEHS_FILES}/btteddy/btteddyk1.cfg"
  BTTEDDY_K1M_URL="${BTTEHS_FILES}/btteddy/btteddyk1max.cfg"
  BTTEDDY_MCU==$(ls /dev/serial/by-id/* | grep "Klipper_rp204")
}

function set_permissions() {

  chmod +x "$CURL" >/dev/null 2>&1 &

}