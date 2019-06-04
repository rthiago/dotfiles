#!/usr/sbin/bash

yay -S --needed --noconfirm ibus tlp i3-battery-popup-git

# Configure Ç on international keyboard (requires ibus package above)
sudo tee -a /etc/environment <<-EOF
GTK_IM_MODULE=cedilla
EOF

sudo gpasswd -a $USER bumblebee

sudo systemctl daemon-reload
sudo systemctl start powertop.service && sudo systemctl enable powertop.service
sudo systemctl start tlp.service && sudo systemctl enable tlp.service
sudo systemctl start tlp-sleep.service && sudo systemctl enable tlp-sleep.service

# @TODO Set nvidia drivers and add 'acpi_osi=! acpi_osi="Windows 2009"' to grub
