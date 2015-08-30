#! /bin/sh

ROOT=/dev/sda2
SWAP=
EFI=
HOME=
VAR=

HOSTNAME=host
USER=server
PASS=password
TIMEZONE=Asia/Taipei
INSTALL_GUI=0
NEED_WIFI=0

mount ${ROOT} /mnt
[[ -n ${SWAP} ]] && swapon ${SWAP}
if [[ -n ${HOME} ]]; then
  mkdir -p /mnt/home
  mount ${HOME} /mnt/home
fi
if [[ -n ${VAR} ]]; then
  mkdir -p /mnt/var
  mount ${VAR} /mnt/var
fi
if [[ -n ${EFI} ]]; then
  mkdir -p /mnt/boot
  mount ${EFI} /mnt/boot
fi

pacstrap /mnt base base-devel
