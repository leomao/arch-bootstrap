#! /bin/zsh
# vim:noet:

cd $HOME
git clone https://aur.archlinux.org/aurman.git
cd aurman
makepkg -si

