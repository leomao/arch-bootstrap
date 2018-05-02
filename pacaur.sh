cd $HOME
gpg --recv-key 1EB2638FF56C0C53
bash <(curl aur.sh) -si cower pacaur
rm -r cower pacaur # cleanup
