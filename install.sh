#!/usr/sbin/bash

if ! hash git 2>/dev/null; then
    echo 'You have to install git first';
    exit;
fi

#git clone https://github.com/rthiago/dotfiles.git ~/projects/dotfiles

ln -s ~/projects/dotfiles/zshrc ~/.zshrc
ln -s ~/projects/dotfiles/gitconfig ~/.gitconfig
ln -s ~/projects/dotfiles/vimrc ~/.vimrc
ln -s ~/projects/dotfiles/tmux.conf.local ~/.tmux.conf.local

# @TODO install .tmux

source ~/.zshrc
