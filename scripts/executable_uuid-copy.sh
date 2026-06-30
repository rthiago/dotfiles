#!/usr/bin/env bash
uuidgen -7 | tr -d '\n' | xclip -selection clipboard
notify-send "UUIDv7 copied to clipboard"

