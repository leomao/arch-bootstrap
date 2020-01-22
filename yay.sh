#! /bin/zsh
# vim:noet:

cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
