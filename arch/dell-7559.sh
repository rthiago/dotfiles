#!/usr/sbin/bash

yay -S --needed --noconfirm tlp i3-battery-popup-git

sudo gpasswd -a $USER bumblebee

sudo systemctl daemon-reload
sudo systemctl start powertop.service && sudo systemctl enable powertop.service
sudo systemctl start tlp.service && sudo systemctl enable tlp.service
sudo systemctl start tlp-sleep.service && sudo systemctl enable tlp-sleep.service

# @TODO Set nvidia drivers and add 'acpi_osi=! acpi_osi="Windows 2009"' to grub
