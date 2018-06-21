#! /bin/zsh

REPODIR=/var/cache/pacman/custom
REPODB=$REPODIR/custom.db.tar
cd $HOME
gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A
repo-add $REPODB
git clone https://aur.archlinux.org/aurutils.git
cd aurutils
makepkg -si
mv *.pkg.tar.xz $REPODIR
cd ..
rm -rf aurtuils
repo-add $REPODB $REPODIR/*.pkg.tar.xz
