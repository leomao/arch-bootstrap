#! /bin/zsh

REPODIR=/var/cache/pacman/custom
REPODB=$REPODIR/custom.db.tar

# pacman local repo and aurutils
sudo install -d $REPODIR -o $USER
cat | sudo tee -a /etc/pacman.d/custom << EOF
[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /var/cache/pacman/custom
CleanMethod = KeepCurrent

[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/custom
EOF
echo "Include = /etc/pacman.d/custom" | sudo tee -a /etc/pacman.conf
sudo sed -i 's/#Color/Color/' /etc/pacman.conf

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
