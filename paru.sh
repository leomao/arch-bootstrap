#! /bin/zsh
# vim:noet:

cd $HOME
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
