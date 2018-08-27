#! /bin/zsh

cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
