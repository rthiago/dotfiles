#!/usr/sbin/bash

if ! hash git 2>/dev/null; then
    echo 'You have to install git first';
    exit;
fi

git clone --recursive git@github.com:rthiago/dotfiles.git ~/projects/dotfiles

ln -s -f ~/projects/dotfiles/zshrc ~/.zshrc
ln -s -f ~/projects/dotfiles/gitconfig ~/.gitconfig
ln -s -f ~/projects/dotfiles/vimrc ~/.vimrc
ln -s -f ~/projects/dotfiles/tmux.conf.local ~/.tmux.conf.local
ln -s -f ~/projects/dotfiles/tmux/.tmux.conf ~/.tmux.conf
