#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <window_class> <launch_command>"
  exit 1
fi

window_class="$1"
launch_command="$2"

active_win_id=$(xdotool getactivewindow)

# Get the window class of the active window
active_win_class=$(xprop -id $active_win_id | grep 'WM_CLASS(STRING)' | awk -F '"' '{print $4}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')

# Debug
# echo $active_win_class > /tmp/foo.txt

# Check if the active window matches the given class
if [[ "$active_win_class" == "$window_class" ]]; then
  xdotool windowminimize $active_win_id
else
  $launch_command &
fi
