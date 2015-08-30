#! /bin/sh

packages=(
  "sudo"
  "ntp"
  "zsh"
  "git"
  "tmux"
  "vim"
  "python"
  "python-pip"
  "nodejs"
  "npm"
  "the_silver_searcher"
)

sed -e "s/^#en_US\.UTF-8/en_US\.UTF-8/" /etc/locale.gen
sed -e "s/^#zh_TW\.UTF-8/zh_TW\.UTF-8/" /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
timedatectl set-timezone ${TIMEZONE}
hwclock --systohc --utc
hostnamectl set-hostname ${HOSTNAME}

useradd -m -G wheel,storage,power ${USER}

echo ${packages[*]} | xargs pacman --force --noconfirm -S
timedatectl set-ntp true
