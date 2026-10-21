#!/bin/sh

set -e

# BTT Eddy Duo install / removal for K1 series.
# Based on Vsevolod-Volkov's K1-Klipper-Eddy, packaged by MikeinRedding.
#
# Every action function called from a menu (install_eddy, remove_eddy, ...)
# must return 0: menus call them through run() under `set -e`, so a non-zero
# return would exit the whole script. Helpers that can fail return 1 and are
# only ever called inside `if`.

EDDY_TESTED_FW="2.3.5.34"

function eddy_message(){
  top_line
  title 'BTT Eddy Duo' "${yellow}"
  inner_line
  hr
  text_line "Replaces PRTouch with a BTT Eddy Duo USB probe for fast"
  text_line "bed mesh scanning, using Vsevolod-Volkov's K1-Klipper-Eddy."
  hr
  text_line "Backups of your configs and Klipper files are kept in" "${white}"
  text_line "${EHS_BACKUP_FOLDER} so it can be removed later." "${white}"
  hr
  bottom_line
}

function eddy_remove_message(){
  top_line
  title 'Remove BTT Eddy Duo' "${yellow}"
  inner_line
  hr
  text_line "Re-enables PRTouch, restores the stock Klipper modules that"
  text_line "Eddy replaced, and undoes the Eddy changes to printer.cfg,"
  text_line "sensorless.cfg and gcode_macro.cfg."
  hr
  text_line "Your other edits are kept. Copies of the files as they are now" "${white}"
  text_line "are saved first in ${EHS_BACKUP_FOLDER}." "${white}"
  hr
  bottom_line
}

#---------------------------------------------------------------------------
# State and detection helpers
#---------------------------------------------------------------------------

function eddy_installed() {
  [ -f "$EDDY_CFG" ] && return 0
  grep -q "include Eddy-Helper/eddy/eddy.cfg" "$PRINTER_CFG" 2>/dev/null
}

function eddy_state_get() {
  # $1 = key; prints value from the install state file, empty if unknown
  [ -f "$EHS_STATE_FILE" ] || return 0
  sed -n "s/^$1=//p" "$EHS_STATE_FILE" | head -n 1
}

function eddy_fw_version() {
  local file="/usr/data/creality/userdata/config/system_version.json"
  [ -f "$file" ] || return 0
  sed -n 's/.*"sys_version"[^"]*"\([^"]*\)".*/\1/p' "$file" | head -n 1
}

function eddy_fw_ok() {
  eddy_fw_version | grep -q "$EDDY_TESTED_FW"
}

function eddy_usb_devices() {
  ls $EDDY_SERIAL_GLOB 2>/dev/null || true
}

function eddy_has_saved_mesh() {
  grep -q "^#\*# \[bed_mesh default\]" "$PRINTER_CFG" 2>/dev/null
}

function nozzle_cleaning_installed() {
  [ -d "$NOZZLE_CLEANING_FOLDER" ] && return 0
  grep -q "include Helper-Script/nozzle-cleaning-fan-control" "$PRINTER_CFG" 2>/dev/null
}

function eddy_screws_using_eddy() {
  [ -L "$SCREWS_ADJUST_FILE" ] && readlink "$SCREWS_ADJUST_FILE" | grep -q -- "-eddy\.cfg" && return 0
  # Older Eddy Helper versions copied the file in place of the link
  [ -f "$SCREWS_ADJUST_FILE" ] && grep -q "Eddy" "$SCREWS_ADJUST_FILE"
}

function eddy_ask_yes_no() {
  # $1 = question. Returns 0 for yes, 1 for no. Call inside `if`.
  local yn
  while true; do
    read -p " ${white}${1} (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y) echo -e "${white}"; return 0;;
      N|n) echo -e "${white}"; return 1;;
      *) error_msg "Please select a correct choice!";;
    esac
  done
}

function eddy_choose_printer() {
  # Sets EDDY_PRINTER to k1 or k1max. Default comes from the last install,
  # then from the printer model reported by the firmware.
  local default printer_choice
  default="$(eddy_state_get printer)"
  if [ -z "$default" ]; then
    if echo "$get_model" | grep -iq "max"; then
      default="k1max"
    else
      default="k1"
    fi
  fi
  while true; do
    read -p " ${white}Is this a ${yellow}K1${white} (untested) or ${yellow}K1 Max${white}? (${yellow}k1${white}/${yellow}k1max${white}, Enter = ${yellow}${default}${white}): ${yellow}" printer_choice
    if [ -z "$printer_choice" ]; then
      printer_choice="$default"
    fi
    case "${printer_choice}" in
      K1|k1)
        EDDY_PRINTER="k1"; break;;
      K1MAX|K1Max|k1Max|k1max|max|MAX)
        EDDY_PRINTER="k1max"; break;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  echo -e "${white}"
}

function eddy_choose_serial() {
  # Sets EDDY_MCU. Returns 1 if no Eddy is connected. Call inside `if`.
  local devices count choice dev i
  EDDY_MCU=""
  devices="$(eddy_usb_devices)"
  count=$(echo "$devices" | grep -c . || true)
  if [ "$count" -eq 0 ]; then
    error_msg "No BTT Eddy found on USB!"
    echo -e " ${darkred}Plug in the Eddy and make sure it is flashed with Klipper${white}"
    echo -e " ${darkred}firmware, then check it shows up with: ls /dev/serial/by-id/${white}"
    echo
    return 1
  elif [ "$count" -eq 1 ]; then
    EDDY_MCU="$devices"
  else
    echo -e "${white}Info: More than one Klipper RP2040 device is connected:"
    i=1
    for dev in $devices; do
      echo -e "   ${yellow}${i}${white}) ${dev}"
      i=$((i + 1))
    done
    while true; do
      read -p " ${white}Which one is the Eddy? (${yellow}1-${count}${white}): ${yellow}" choice
      case "${choice}" in
        ''|*[!0-9]*)
          error_msg "Please select a correct choice!";;
        *)
          if [ "$choice" -ge 1 ] && [ "$choice" -le "$count" ]; then
            EDDY_MCU="$(echo "$devices" | sed -n "${choice}p")"
            break
          fi
          error_msg "Please select a correct choice!";;
      esac
    done
  fi
  echo -e "${white}Info: Using Eddy on ${yellow}${EDDY_MCU}${white}"
  return 0
}

function eddy_set_serial() {
  sed -i "s|^serial: /dev/serial/by-id/usb-Klipper_rp2040.*|serial: ${EDDY_MCU}|" "$EDDY_CFG"
  if [ -f "$EHS_STATE_FILE" ]; then
    sed -i '/^serial=/d' "$EHS_STATE_FILE"
    echo "serial=${EDDY_MCU}" >> "$EHS_STATE_FILE"
  fi
}

function eddy_link_screws() {
  # $1 = k1|k1max, $2 = eddy|stock. Only acts if Screws Tilt Adjust is installed.
  local url
  [ -e "$SCREWS_ADJUST_FILE" ] || [ -L "$SCREWS_ADJUST_FILE" ] || return 0
  case "$1-$2" in
    k1-eddy) url="$SCREWS_ADJUST_K1_EDDY_URL";;
    k1max-eddy) url="$SCREWS_ADJUST_K1M_EDDY_URL";;
    k1-stock) url="$SCREWS_ADJUST_K1_URL";;
    *) url="$SCREWS_ADJUST_K1M_URL";;
  esac
  rm -f "$SCREWS_ADJUST_FILE"
  ln -sf "$url" "$SCREWS_ADJUST_FILE"
}

#---------------------------------------------------------------------------
# Pre-install checks
#---------------------------------------------------------------------------

function eddy_preflight() {
  # Prints every blocking problem; returns 1 if any. Call inside `if`.
  local failed=0
  if eddy_installed; then
    error_msg "BTT Eddy Duo is already installed!"
    return 1
  fi
  if nozzle_cleaning_installed; then
    error_msg "Nozzle Cleaning Fan Control is installed!"
    echo -e " ${darkred}It needs PRTouch, which Eddy disables, so Klipper would not start.${white}"
    echo -e " ${darkred}Remove it first from the [Remove] Menu.${white}"
    echo
    failed=1
  fi
  if ! eddy_has_saved_mesh; then
    error_msg "No saved bed mesh named 'default' in printer.cfg!"
    echo -e " ${darkred}Run BED_MESH_CALIBRATE then SAVE_CONFIG with PRTouch first.${white}"
    echo -e " ${darkred}(or paste the mesh from bedmesh.txt into your SAVE_CONFIG block)${white}"
    echo
    failed=1
  fi
  if ! grep -q "^\[include printer_params\.cfg\]" "$PRINTER_CFG" \
     || ! grep -q "^\[prtouch_v2\]" "$PRINTER_CFG" \
     || ! grep -q "^\[display_status\]" "$PRINTER_CFG"; then
    error_msg "printer.cfg does not look like the stock K1 file!"
    echo -e " ${darkred}Expected [include printer_params.cfg], [prtouch_v2] and${white}"
    echo -e " ${darkred}[display_status] sections. Eddy needs a factory-fresh printer.cfg.${white}"
    echo
    failed=1
  fi
  if [ ! -f "$SENSORLESS_CFG" ] || ! grep -q "^\[gcode_macro _IF_HOME_Z\]" "$SENSORLESS_CFG"; then
    error_msg "sensorless.cfg is missing or not stock!"
    echo -e " ${darkred}Expected a [gcode_macro _IF_HOME_Z] section in ${SENSORLESS_CFG}.${white}"
    echo
    failed=1
  fi
  return $failed
}

function eddy_warnings() {
  # Non-blocking issues; asks to continue if any. Returns 1 to cancel.
  local warned=0 fw
  fw="$(eddy_fw_version)"
  if ! eddy_fw_ok; then
    echo -e " ${yellow}! Firmware is ${fw:-unknown}. Eddy was only tested on ${EDDY_TESTED_FW};${white}"
    echo -e " ${yellow}  2.3.5.33 is known to cause problems.${white}"
    warned=1
  fi
  if [ ! -d "$MOONRAKER_FOLDER" ] || { [ ! -d "$MAINSAIL_FOLDER" ] && [ ! -d "$FLUIDD_FOLDER" ]; }; then
    echo -e " ${yellow}! Moonraker + Mainsail (or Fluidd) are not installed. You need a${white}"
    echo -e " ${yellow}  Klipper console for the Eddy calibration steps.${white}"
    warned=1
  fi
  if [ -f "$SAVE_ZOFFSET_FILE" ]; then
    echo -e " ${yellow}! Save Z-Offset Macros are installed. They are untested with Eddy${white}"
    echo -e " ${yellow}  and may fight with Eddy's own Z offset handling.${white}"
    warned=1
  fi
  if [ -d "$KAMP_FOLDER" ]; then
    echo -e " ${yellow}! KAMP is installed. It is untested with Eddy.${white}"
    warned=1
  fi
  if [ "$warned" -eq 1 ]; then
    echo
    if ! eddy_ask_yes_no "Continue anyway?"; then
      return 1
    fi
  fi
  return 0
}

#---------------------------------------------------------------------------
# Klipper module overlay (backed up so it can be undone)
#---------------------------------------------------------------------------

function eddy_install_klippy() {
  local klippy="${EDDY_KLIPPER_FOLDER}/klippy" rel dst
  echo -e "Info: Backing up and replacing Klipper modules..."
  rm -rf "$EDDY_KLIPPY_BACKUP"
  mkdir -p "$EDDY_KLIPPY_BACKUP"
  : > "$EDDY_NEW_FILES_LIST"
  (cd "$EDDY_KLIPPY" && find . -type f | sed 's#^\./##') > "${EHS_BACKUP_FOLDER}/klippy-files.list"
  while read -r rel; do
    [ -n "$rel" ] || continue
    dst="${klippy}/${rel}"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      mkdir -p "$(dirname "${EDDY_KLIPPY_BACKUP}/${rel}")"
      cp -a "$dst" "${EDDY_KLIPPY_BACKUP}/${rel}"
    else
      echo "$rel" >> "$EDDY_NEW_FILES_LIST"
    fi
    # Stock firmware ships some modules only as compiled .pyc
    if [ -e "${dst}c" ]; then
      mkdir -p "$(dirname "${EDDY_KLIPPY_BACKUP}/${rel}")"
      cp -a "${dst}c" "${EDDY_KLIPPY_BACKUP}/${rel}c"
    fi
    mkdir -p "$(dirname "$dst")"
    # Remove first: the target may be a symlink into this repo (e.g.
    # gcode_shell_command.py), and copying onto it would edit the repo file.
    rm -f "$dst" "${dst}c"
    cp "${EDDY_KLIPPY}/${rel}" "$dst"
  done < "${EHS_BACKUP_FOLDER}/klippy-files.list"
}

function eddy_helper_managed() {
  # True if $1 is a symlink into this repo, i.e. a helper option installed
  # after Eddy owns it now (Screws Tilt Adjust, Gcode Shell Command, KAMP).
  [ -L "$1" ] && readlink "$1" | grep -q "^${HELPER_SCRIPT_FOLDER}/"
}

function eddy_restore_klippy() {
  local klippy="${EDDY_KLIPPER_FOLDER}/klippy" rel
  if [ -f "$EDDY_NEW_FILES_LIST" ]; then
    echo -e "Info: Removing Klipper modules added by Eddy..."
    while read -r rel; do
      [ -n "$rel" ] || continue
      if eddy_helper_managed "${klippy}/${rel}"; then
        continue
      fi
      rm -f "${klippy}/${rel}" "${klippy}/${rel}c"
    done < "$EDDY_NEW_FILES_LIST"
  fi
  if [ -d "$EDDY_KLIPPY_BACKUP" ]; then
    echo -e "Info: Restoring stock Klipper modules..."
    (cd "$EDDY_KLIPPY_BACKUP" && find . \( -type f -o -type l \) | sed 's#^\./##') > "${EHS_BACKUP_FOLDER}/klippy-restore.list"
    while read -r rel; do
      [ -n "$rel" ] || continue
      if eddy_helper_managed "${klippy}/${rel}"; then
        continue
      fi
      rm -f "${klippy}/${rel}"
      mkdir -p "$(dirname "${klippy}/${rel}")"
      cp -a "${EDDY_KLIPPY_BACKUP}/${rel}" "${klippy}/${rel}"
    done < "${EHS_BACKUP_FOLDER}/klippy-restore.list"
    rm -f "${EHS_BACKUP_FOLDER}/klippy-restore.list"
  fi
  rmdir "${klippy}/extras/upgrade" "${klippy}/upgrade" 2>/dev/null || true
}

#---------------------------------------------------------------------------
# Config edits
#---------------------------------------------------------------------------

function eddy_patch_configs() {
  local temp_file force_move_added=0

  echo -e "Info: Adding Eddy configurations in printer.cfg file..."
  sed -i '/^\[include printer_params\.cfg\]/a \[include Eddy-Helper/eddy/eddy\.cfg\]' "$PRINTER_CFG"
  sed -i '/^\[include printer_params\.cfg\]/a \[include Eddy-Helper/eddy/fan_control\.cfg\]' "$PRINTER_CFG"

  echo -e "Info: Disabling PRTouch in printer.cfg file..."
  # PRTouch MCU
  sed -i '/^\[mcu leveling_mcu\]/,/restart_method: command/s/^/#/' "$PRINTER_CFG"
  # Z endstop: use Eddy as virtual endstop
  sed -i '/endstop_pin: tmc2209_stepper_z:virtual_endstop/s/^[ \t]*[^#]/#&/' "$PRINTER_CFG"
  sed -i '/^#[ \t]*endstop_pin: tmc2209_stepper_z:virtual_endstop/a endstop_pin: probe:z_virtual_endstop' "$PRINTER_CFG"
  sed -i '/^\[stepper_z\]/,/^\[/{/^position_endstop: 0/s/^/#/}' "$PRINTER_CFG"
  # PRTouch section (everything up to [display_status])
  sed -i '/^\[prtouch_v2\]/,/^\[display_status\]/{/^\[display_status\]/!s/^/#/}' "$PRINTER_CFG"
  # force_move is needed for FAKE_HOME during calibration
  if ! grep -rqs "^\[force_move\]" "$KLIPPER_CONFIG_FOLDER"/*.cfg "$KLIPPER_CONFIG_FOLDER"/Helper-Script; then
    sed -i '/^\[mcu\]/i\
[force_move]\
enable_force_move: True\
' "$PRINTER_CFG"
    force_move_added=1
  fi
  echo "force_move_added=${force_move_added}" >> "$EHS_STATE_FILE"

  echo -e "Info: Updating homing in sensorless.cfg file..."
  if ! grep -q "rename_existing: G0028" "$SENSORLESS_CFG"; then
    sed -i 's/\bG28\b/G0028/g' "$SENSORLESS_CFG"
    temp_file=$(mktemp)
    cat <<'EOF' > "$temp_file"
[gcode_macro G28]
rename_existing: G0028
gcode:
  {% set POSITION_X = printer.configfile.settings['stepper_x'].position_max/2 %}
  {% set POSITION_Y = printer.configfile.settings['stepper_y'].position_max/2 %}
  G0028 {rawparams}
  G90 ; Set to Absolute Positioning
  G0 X{POSITION_X} Y{POSITION_Y} F3000 ; Move to bed center
  {% if not rawparams or (rawparams and 'Z' in rawparams) %}
    PROBE
    SET_Z_FROM_PROBE
  {% endif %}

[gcode_macro _IF_HOME_Z]
EOF
    sed -i -e '\|^\[gcode_macro _IF_HOME_Z\]|!b' -e "r $temp_file" -e 'd' "$SENSORLESS_CFG"
    rm -f "$temp_file"
  fi

  echo -e "Info: Adding FAKE_HOME macro in gcode_macro.cfg file..."
  if ! grep -q "^\[gcode_macro FAKE_HOME\]" "$MACROS_CFG"; then
    cat <<'EOF' >> "$MACROS_CFG"

[gcode_macro FAKE_HOME]
gcode:
  # Caution: This command is for debugging only. Do not use it
  # during normal operations or printing.
  RESPOND MSG="!! Setting kinematic position to X=150 Y=150 Z=100 !!"
  SET_KINEMATIC_POSITION X=150 Y=150 Z=100
EOF
  fi
}

function eddy_unpatch_configs() {
  local force_move_added temp_file
  force_move_added="$(eddy_state_get force_move_added)"

  echo -e "Info: Removing Eddy configurations from printer.cfg file..."
  sed -i '/include Eddy-Helper\/eddy\/eddy\.cfg/d' "$PRINTER_CFG"
  sed -i '/include Eddy-Helper\/eddy\/fan_control\.cfg/d' "$PRINTER_CFG"

  echo -e "Info: Re-enabling PRTouch in printer.cfg file..."
  # Older versions commented this block twice, so strip all leading #
  sed -i '/^#*\[mcu leveling_mcu\]/,/restart_method: command/s/^#*//' "$PRINTER_CFG"
  sed -i '/^endstop_pin: probe:z_virtual_endstop/d' "$PRINTER_CFG"
  sed -i 's/^#\([ \t]*endstop_pin: tmc2209_stepper_z:virtual_endstop\)/\1/' "$PRINTER_CFG"
  sed -i 's/^#\(position_endstop: 0\)/\1/' "$PRINTER_CFG"
  sed -i '/^#\[prtouch_v2\]/,/^\[display_status\]/{/^\[display_status\]/!s/^#//}' "$PRINTER_CFG"
  # Older versions always added [force_move]; newer ones record it
  if [ "$force_move_added" = "1" ] || [ ! -f "$EHS_STATE_FILE" ]; then
    sed -i '/^\[force_move\]/,/enable_force_move: True/d' "$PRINTER_CFG"
  fi

  echo -e "Info: Removing Eddy calibration from SAVE_CONFIG block..."
  temp_file=$(mktemp)
  awk '
    /^#\*# \[/ { skip = ($0 ~ /^#\*# \[(probe_eddy_current|temperature_probe) btt_eddy\]/) }
    !skip { print }
  ' "$PRINTER_CFG" > "$temp_file"
  cat "$temp_file" > "$PRINTER_CFG"
  rm -f "$temp_file"

  if [ -f "$SENSORLESS_CFG" ] && grep -q "rename_existing: G0028" "$SENSORLESS_CFG"; then
    echo -e "Info: Restoring homing in sensorless.cfg file..."
    sed -i '/^\[gcode_macro G28\]/,/^\[gcode_macro _IF_HOME_Z\]/{/^\[gcode_macro _IF_HOME_Z\]/!d}' "$SENSORLESS_CFG"
    sed -i 's/\bG0028\b/G28/g' "$SENSORLESS_CFG"
  fi

  if grep -q "^\[gcode_macro FAKE_HOME\]" "$MACROS_CFG"; then
    echo -e "Info: Removing FAKE_HOME macro from gcode_macro.cfg file..."
    # Drop the macro and the one blank line that was added with it
    temp_file=$(mktemp)
    awk '
      { lines[NR] = $0 }
      END {
        n = 0
        for (i = 1; i <= NR; i++) {
          if (lines[i] ~ /^\[gcode_macro FAKE_HOME\]/) {
            j = i
            while (j < NR && lines[j] !~ /SET_KINEMATIC_POSITION X=150 Y=150 Z=100/) j++
            if (n > 0 && out[n] ~ /^[ \t]*$/) n--
            else if (j < NR && lines[j + 1] ~ /^[ \t]*$/) j++
            i = j
            continue
          }
          out[++n] = lines[i]
        }
        for (i = 1; i <= n; i++) print out[i]
      }
    ' "$MACROS_CFG" > "$temp_file"
    cat "$temp_file" > "$MACROS_CFG"
    rm -f "$temp_file"
  fi
}

function eddy_backup_configs() {
  # $1 = destination folder
  mkdir -p "$1"
  cp -f "$PRINTER_CFG" "$MACROS_CFG" "$1"/
  if [ -f "$SENSORLESS_CFG" ]; then
    cp -f "$SENSORLESS_CFG" "$1"/
  fi
}

function eddy_next_steps() {
  top_line
  title 'Next: calibrate the Eddy' "${yellow}"
  inner_line
  hr
  text_line "From the Mainsail/Fluidd console:" "${white}"
  text_line " 1. FAKE_HOME, move head to bed center, Eddy 20mm above bed"
  text_line " 2. LDC_CALIBRATE_DRIVE_CURRENT CHIP=btt_eddy, then SAVE_CONFIG"
  text_line " 3. FAKE_HOME, then PROBE_EDDY_CURRENT_CALIBRATE_AUTO"
  text_line "    CHIP=btt_eddy (paper test), then SAVE_CONFIG"
  text_line " 4. Home all and run a bed mesh"
  text_line " 5. Do BTT's temperature compensation calibration"
  hr
  text_line "Full steps: github.com/mikeinredding/K1Max-Klipper-Eddy" "${white}"
  hr
  bottom_line
}

#---------------------------------------------------------------------------
# Menu actions (must always return 0)
#---------------------------------------------------------------------------

function install_eddy(){
  eddy_message
  local yn
  while true; do
    install_msg "BTT Eddy Duo" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if ! eddy_preflight; then
          error_msg "Installation canceled, nothing was changed."
          return 0
        fi
        if ! eddy_warnings; then
          error_msg "Installation canceled, nothing was changed."
          return 0
        fi
        if ! eddy_choose_serial; then
          error_msg "Installation canceled, nothing was changed."
          return 0
        fi
        eddy_choose_printer

        echo -e "Info: Backing up configuration files..."
        mkdir -p "$EHS_BACKUP_FOLDER"
        eddy_backup_configs "${EHS_BACKUP_FOLDER}/pre-eddy"
        {
          echo "printer=${EDDY_PRINTER}"
          echo "serial=${EDDY_MCU}"
          echo "installed=$(date '+%Y-%m-%d %H:%M:%S')"
          echo "firmware=$(eddy_fw_version)"
        } > "$EHS_STATE_FILE"

        echo -e "Info: Copying Eddy configuration files..."
        mkdir -p "$EDDY_FOLDER"
        if [ "$EDDY_PRINTER" = "k1max" ]; then
          cp -f "$EDDY_K1M_URL" "$EDDY_CFG"
        else
          cp -f "$EDDY_K1_URL" "$EDDY_CFG"
        fi
        cp -f "$EDDY_FAN_URL" "$EDDY_FAN_CFG"
        eddy_set_serial

        eddy_install_klippy
        eddy_patch_configs

        if [ -e "$SCREWS_ADJUST_FILE" ] || [ -L "$SCREWS_ADJUST_FILE" ]; then
          echo -e "Info: Switching Screws Tilt Adjust to Eddy probe positions..."
          eddy_link_screws "$EDDY_PRINTER" eddy
        fi

        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "BTT Eddy Duo has been installed successfully!"
        eddy_next_steps
        return 0;;
      N|n)
        error_msg "Installation canceled!"
        return 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_eddy(){
  eddy_remove_message
  local yn printer stamp
  while true; do
    remove_msg "BTT Eddy Duo" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        stamp="$(date '+%Y%m%d-%H%M%S')"
        echo -e "Info: Saving current configuration files..."
        eddy_backup_configs "${EHS_BACKUP_FOLDER}/removed-${stamp}"

        eddy_unpatch_configs
        if [ -d "$EDDY_KLIPPY_BACKUP" ]; then
          eddy_restore_klippy
        else
          echo -e "${yellow}Warning: No backup of the stock Klipper modules was found (Eddy was${white}"
          echo -e "${yellow}installed with an older version of this script). The Eddy Klipper${white}"
          echo -e "${yellow}modules stay in place. If Klipper misbehaves, reinstall the firmware.${white}"
        fi

        echo -e "Info: Removing Eddy configuration files..."
        rm -rf "$EDDY_FOLDER"
        if [ -d "$EHS_CONFIG_FOLDER" ] && [ -z "$(ls -A "$EHS_CONFIG_FOLDER")" ]; then
          rm -rf "$EHS_CONFIG_FOLDER"
        fi

        if eddy_screws_using_eddy; then
          printer="$(eddy_state_get printer)"
          if [ -z "$printer" ]; then
            eddy_choose_printer
            printer="$EDDY_PRINTER"
          fi
          echo -e "Info: Switching Screws Tilt Adjust back to stock positions..."
          eddy_link_screws "$printer" stock
        fi

        # Keep the pre-install copies with this removal, start fresh next time
        if [ -d "${EHS_BACKUP_FOLDER}/pre-eddy" ]; then
          mv "${EHS_BACKUP_FOLDER}/pre-eddy" "${EHS_BACKUP_FOLDER}/removed-${stamp}/pre-eddy"
        fi
        rm -rf "$EDDY_KLIPPY_BACKUP"
        rm -f "$EDDY_NEW_FILES_LIST" "${EHS_BACKUP_FOLDER}/klippy-files.list" "$EHS_STATE_FILE"

        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "BTT Eddy Duo has been removed successfully!"
        echo -e " ${white}PRTouch is active again. Previous files are in:${white}"
        echo -e " ${yellow}${EHS_BACKUP_FOLDER}/removed-${stamp}${white}"
        echo
        return 0;;
      N|n)
        error_msg "Deletion canceled!"
        return 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function redetect_eddy_serial(){
  if eddy_choose_serial; then
    eddy_set_serial
    echo -e "Info: Restarting Klipper service..."
    restart_klipper
    ok_msg "Eddy serial updated in eddy.cfg!"
  fi
  return 0
}

function toggle_eddy_screws_tilt(){
  local target
  if eddy_screws_using_eddy; then
    target="stock"
  else
    target="eddy"
  fi
  if ! eddy_ask_yes_no "Switch Screws Tilt Adjust to ${target} probe positions?"; then
    error_msg "Canceled!"
    return 0
  fi
  eddy_choose_printer
  eddy_link_screws "$EDDY_PRINTER" "$target"
  echo -e "Info: Restarting Klipper service..."
  restart_klipper
  ok_msg "Screws Tilt Adjust now uses ${target} probe positions!"
  return 0
}
