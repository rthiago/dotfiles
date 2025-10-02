#!/usr/bin/env bash
uuidgen -7 | tr -d '\n' | wl-copy
notify-send "UUIDv7 copied to clipboard"

