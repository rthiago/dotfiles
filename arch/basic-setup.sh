#!/usr/sbin/bash

# Add Sublime official repo
if ! grep -q 'sublime-text' /etc/pacman.conf; then
    curl -O https://download.sublimetext.com/sublimehq-pub.gpg
    sudo pacman-key --add sublimehq-pub.gpg
    sudo pacman-key --lsign-key 8A8F901A
    rm sublimehq-pub.gpg
    echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64\n" | sudo tee -a /etc/pacman.conf
fi

sudo pacman -S --noconfirm yay

yay -Syua --noconfirm

yay -S --needed --noconfirm adobe-source-sans-pro-fonts ananicy-git apache automake cifs-utils cronie docker dropbox exfat-utils file-roller firefox flac fuse-common fuse-exfat fzf git google-chrome gparted gpmdp hdparm htop httpie icedtea-web imagemagick intel-ucode iotop net-tools openssh pkgfile powertop pygmentize screen ttf-hack ttf-liberation ttf-ms-fonts ttf-ubuntu-font-family ttf-vista-fonts vim xclip wget zsh-syntax-highlighting telegram-desktop-bin terminator dropbox-cli php python tor nmap proxychains-ng aircrack-ng crunch rfkill bc ltrace strace alsa-utils sslstrip dsniff ntp redis ctop transmission-gtk mpv sublime-text usbguard gimp jq tmux diff-so-fancy meld

sudo usermod -aG docker $USER

sudo systemctl start docker && sudo systemctl enable docker
sudo systemctl start ananicy && sudo systemctl enable ananicy
sudo systemctl start cronie && sudo systemctl enable cronie
sudo systemctl start ntpd && sudo systemctl enable ntpd
sudo systemctl start pkgfile-update.timer && sudo systemctl enable pkgfile-update.timer

# Improves responsiveness
sudo tee -a /etc/sysctl.d/99-sysctl.conf <<-EOF
vm.swappiness=1
vm.vfs_cache_pressure=50
vm.dirty_background_bytes=16777216
vm.dirty_bytes=50331648
EOF

# Handles magnet link to transmission
gio mime x-scheme-handler/magnet transmission-gtk.desktop

# Uninstall orphan packages
sudo pacman -Rns $(pacman -Qtdq)

chsh -s /usr/bin/zsh

sudo rm /usr/sbin/vi
sudo ln -s /usr/sbin/vim /usr/sbin/vi
