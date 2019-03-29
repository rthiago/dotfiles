#!/usr/sbin/bash

yay -S --needed --noconfirm ibus

# Configure Ç on international keyboard (requires ibus package above)
sudo tee -a /etc/environment <<-EOF
GTK_IM_MODULE=cedilla
EOF

sudo gpasswd -a $USER bumblebee

# Autostart powertop autotune
cat << EOF | sudo tee /etc/systemd/system/powertop.service
[Unit]
Description=PowerTOP auto tune

[Service]
Type=idle
Environment="TERM=dumb"
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start powertop.service && sudo systemctl enable powertop.service

# @TODO Set nvidia drivers and add 'acpi_osi=! acpi_osi="Windows 2009"' to grub
