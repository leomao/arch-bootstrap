#! /bin/zsh

cd $HOME
git clone https://aur.archlinux.org/aurman.git
cd aurman
makepkg -si

