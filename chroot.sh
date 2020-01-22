#! /bin/zsh -e
# vim:noet:

# NOTE: you *will* want change these lines...
export HOSTNAME=host
export USER=server
export PASS=password
export TIMEZONE=Asia/Taipei

# variable from bootstrap.sh
export ROOT_PART=$1

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
systemctl enable cups-browsed # for printer
# NOTE: if you don't want to use gnome, the following lines are useless...
systemctl enable NetworkManager
systemctl enable gdm
sed -i 's/#\(WaylandEnable\)/\1/' /etc/gdm/custom.conf # disable wayland

# boot loader
bootctl install

# install intel-ucode if cpu is intel
cpu_vendor=$(lscpu | grep Vendor | awk -F ': +' '{print $2}')
if [[ $cpu_vendor == "GenuineIntel" ]]; then
	pacman -S intel-ucode
fi

# assume root partition is /dev/sdxY
export PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PART})
# iterate over possible kernels in the official repo
for k in linux linux-lts linux-zen linux-hardened; do
	if pacman -Q $k; then
		name=${k//linux/arch}
		title="Arch Linux"
		if [[ "$k" =~ "^linux-(.*)" ]]; then
			# so... use BASH_REMATCH instead of match if using bash
			title="$title (${match[1]})"
		fi
		conf_path="/boot/loader/entries/$name.conf"
		cat > $conf_path <<- EOF
			title	${title}
			linux	/vmlinuz-${k}
			initrd	/initramfs-${k}.img
			options	root=PARTUUID=${PARTUUID} rw
		EOF
		if [[ $cpu_vendor == "GenuineIntel" ]]; then
			sed -i -e '3i initrd	/intel-ucode.img' $conf_path
		fi
		if [[ -z $default_kernel ]]; then
			default_kernel=$name
		fi
	fi
done

if [[ -z $default_kernel ]]; then
	echo "You don't have any kernel installed!?"
	exit 1
fi

cat > /boot/loader/loader.conf << EOF
default	${default_kernel}
timeout	3
editor	0
EOF

# sudo
sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers

useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASS" | chpasswd
# disable root login
passwd -l root

exit
