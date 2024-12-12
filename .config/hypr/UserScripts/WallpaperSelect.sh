#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */ 
# This script for selecting wallpapers (SUPER W)

# WALLPAPERS PATH
wallDIR="$HOME/Pictures/wallpapers/vert"
rigtDIR="$HOME/Pictures/wallpapers/wide"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# variables
focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
right_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: no/{print name; exit}')
FPS=60
TYPE="any"
DURATION=1.5
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

# Check if swaybg is running and kill it if it is
if pidof swaybg > /dev/null; then
  pkill swaybg
fi

# Retrieve image files based on monitor configuration
if [[ "$focused_monitor" == "$right_monitor" ]]; then
  echo "Error: Only one monitor detected."
  exit 1
fi

# Determine which directory to use for which monitor
if [[ "$focused_monitor" == "LVDS-1" || "$focused_monitor" == "VGA-1" ]]; then
  focused_dir="$wallDIR"
  right_dir="$rigtDIR"
else
  focused_dir="$rigtDIR"
  right_dir="$wallDIR"
fi

mapfile -d '' FOCUSED_PICS < <(find "$focused_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)
mapfile -d '' RIGHT_PICS < <(find "$right_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)

# Select random pictures
RANDOM_FOCUSED_PIC="${FOCUSED_PICS[$((RANDOM % ${#FOCUSED_PICS[@]}))]}"
RANDOM_RIGHT_PIC="${RIGHT_PICS[$((RANDOM % ${#RIGHT_PICS[@]}))]}"
RANDOM_PIC_NAME="random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

# Sorting Wallpapers
menu() {
  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_FOCUSED_PIC"
  for pic_path in $(printf '%s\n' "${FOCUSED_PICS[@]}" | sort); do
    pic_name=$(basename "$pic_path")
    if [[ ! "$pic_name" =~ \.gif$ ]]; then
      echo -e "$(echo "$pic_name" | cut -d. -f1)\x00icon\x1f$pic_path"
    else
      echo "$pic_name"
    fi
  done
}

# Initiate swww if not running
if ! swww query; then
  swww-daemon --format xrgb
fi

# Choice of wallpapers
main() {
  choice=$(menu | $rofi_command)
  
  if [[ -z "$choice" ]]; then
    echo "No choice selected. Exiting."
    return 1
  fi

  selected_focused_pic=""
  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    selected_focused_pic="$RANDOM_FOCUSED_PIC"
    selected_right_pic="$RANDOM_RIGHT_PIC"
  else
    for pic in "${FOCUSED_PICS[@]}"; do
      if [[ "$(basename "$pic")" == "$choice"* ]]; then
        selected_focused_pic="$pic"
        selected_right_pic="${RIGHT_PICS[$((RANDOM % ${#RIGHT_PICS[@]}))]}"
        break
      fi
    done
  fi

  if [[ -n "$selected_focused_pic" ]]; then
    swww img -o "$focused_monitor" "$selected_focused_pic" $SWWW_PARAMS
    swww img -o "$right_monitor" "$selected_right_pic" $SWWW_PARAMS
    echo "Wallpapers set successfully."
    sleep 1.5
    "$SCRIPTSDIR/WallustSwww.sh"
    sleep 0.5
    "$SCRIPTSDIR/Refresh.sh"
  else
    echo "Image not found for focused monitor."
    return 1
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  sleep 1 
fi

main