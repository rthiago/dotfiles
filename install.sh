#!/usr/sbin/bash

if ! hash git 2>/dev/null; then
    echo 'You have to install git first';
    exit;
fi

git clone --recursive git@github.com:rthiago/dotfiles.git ~/projects/dotfiles

mkdir -p ~/.config/alacritty
mkdir -p ~/.config/i3

ln -s -f ~/projects/dotfiles/zshrc ~/.zshrc
ln -s -f ~/projects/dotfiles/gitconfig ~/.gitconfig
ln -s -f ~/projects/dotfiles/vimrc ~/.vimrc
ln -s -f ~/projects/dotfiles/tmux.conf.local ~/.tmux.conf.local
ln -s -f ~/projects/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -s -f ~/projects/dotfiles/oh-my-zsh ~/.oh-my-zsh
ln -s -f ~/projects/dotfiles/alacritty.yml ~/.config/alacritty/alacritty.yml
ln -s -f ~/projects/dotfiles/polybar_config ~/.config/polybar
ln -s -f ~/projects/dotfiles/i3_config ~/.config/i3/config
ln -s -f ~/projects/dotfiles/compton.conf ~/.config/compton.conf
