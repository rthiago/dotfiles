#!/bin/bash

# Example:
# /home/thiago/scripts/toggle-app.sh "Subl" "subl" "subl.Subl"

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <window_title> <launch_command> <window_class>"
  exit 1
fi

window_title="$1"
launch_command="$2"
window_class="$3"

active_win_id=$(xdotool getactivewindow)

# Get the window class of the active window
active_win_class=$(xprop -id $active_win_id | grep 'WM_CLASS(STRING)' | awk -F '"' '{print $4}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')

# Debug
# echo $active_win_class > /tmp/foo.txt

# Check if the active window matches the given class
if [[ "$active_win_class" == "$window_title" ]]; then
  xdotool windowminimize $active_win_id
else
  existing_win_id=$(wmctrl -lx | grep "$window_class" | awk '{print $1}' | head -n 1)
  
  # Check if the app is already running
  if [ -z "$existing_win_id" ]; then
    # Launch the app if not running
    $launch_command &
  else
    # Activate the existing app window
    wmctrl -i -a $existing_win_id
  fi

fi
