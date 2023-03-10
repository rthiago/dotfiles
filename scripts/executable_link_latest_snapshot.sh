#!/bin/bash

LATEST_ROOT="$(snapper -c root list | grep timeline | tail -n1 | awk -F\| '{print $1}' | tr -d ' ')"
LATEST_HOME="$(snapper -c home list | grep timeline | tail -n1 | awk -F\| '{print $1}' | tr -d ' ')"

ln -sfn /.snapshots/$LATEST_ROOT /.snapshots/latest
ln -sfn /home/.snapshots/$LATEST_HOME /home/.snapshots/latest
