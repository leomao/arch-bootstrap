#! /bin/zsh -e

export HOSTNAME=host
export USER=server
export PASS=password
export TIMEZONE=Asia/Taipei
export ROOT_PART=/dev/sda3

# locale
sed -i 's/^#\(en_US\|zh_TW\)\(\.UTF-8\)/\1\2/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# timezone and time sync
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# hostname
echo $HOSTNAME > /etc/hostname
sed -i "8i 127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" /etc/hosts

# startup daemon
systemctl enable fstrim.timer # only need if using SSD
systemctl enable NetworkManager
systemctl enable gdm
sed -i 's/#\(WaylandEnable\)/\1/' /etc/gdm/custom.conf # Wayland is not stable...
systemctl enable cups-browsed # for printer

# boot loader
bootctl install
cat > /boot/loader/loader.conf << EOF
default	arch
timeout	3
editor	0
EOF

# assume root partition is /dev/sdxY
export PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PART})
cat > /boot/loader/entries/arch.conf << EOF
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options root=PARTUUID=${PARTUUID} rw
EOF
# add intel-ucode if cpu is intel
cpu_vendor=$(lscpu | grep Vendor | awk -F ': +' '{print $2}')
if [[ $cpu_vendor == "GenuineIntel" ]]; then
  pacman -S intel-ucode
  sed -i -e '3i initrd	/intel-ucode.img' /boot/loader/entries/arch.conf
fi

# sudo
sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers

useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASS" | chpasswd

exit
