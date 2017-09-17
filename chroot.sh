#! /bin/sh

export HOSTNAME=host
export USER=server
export PASS=password
export TIMEZONE=Asia/Taipei
export ROOT_PART=/dev/sda3

# 語系
sed -i -e 's/^#\(en_US\|zh_TW\)\(\.UTF-8\)/\1\2/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 時間
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# hostname 相關
echo $HOSTNAME > /etc/hostname
sed -ie "8i 127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" /etc/hosts

# 一些需要開機做的事
systemctl enable fstrim.timer # 好像是有 SSD 才需要
systemctl enable NetworkManager
systemctl enable gdm
sed -ie 's/#\(WaylandEnable\)/\1/' /etc/gdm/custom.conf # Wayland 還不太穩...
systemctl enable cups-browsed # 如果要用 printer

# boot loader
bootctl install
cat > /boot/loader/loader.conf << EOF
default	arch
timeout	3
editor	0
EOF
cat > /boot/loader/entries/arch.conf << EOF
title	Arch Linux
linux	/vmlinuz-linux
initrd	/intel-ucode.img
initrd	/initramfs-linux.img
options root=PARTUUID=<PARTUUID> rw
EOF
# assume root partition is /dev/sdxY
export PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PART})
sed -ie "s/<PARTUUID>/${PARTUUID}/" /boot/loader/entries/arch.conf
# sudo
sed -ie 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers

useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASS" | chpasswd

sudo -u $USER bash /tmp/scripts/pacaur.sh

exit
