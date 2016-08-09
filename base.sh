#! /bin/sh

function install_packages() {
  xargs pacman --force --noconfirm -S "$@"
}

function locale_setting() {
  sed -e "s/^#en_US\.UTF-8/en_US\.UTF-8/" /etc/locale.gen
  sed -e "s/^#zh_TW\.UTF-8/zh_TW\.UTF-8/" /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function time_setting() {
  timedatectl set-timezone ${TIMEZONE}
  hwclock --systohc --utc
  timedatectl set-ntp true
}

basic_packages=(
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


hostnamectl set-hostname ${HOSTNAME}
useradd -m -G wheel,storage,power ${USER}

