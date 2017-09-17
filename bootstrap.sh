#! /bin/sh

ROOT_PART=/dev/sda3
SWAP_PART=/dev/sda2
EFI_PART=/dev/sda1
HOME_PART=/dev/sdb2
VAR_PART=/dev/sdb1

mount ${ROOT_PART} /mnt
[[ -n ${SWAP_PART} ]] && swapon ${SWAP_PART}
if [[ -n ${HOME_PART} ]]; then
  mkdir -p /mnt/home
  mount ${HOME_PART} /mnt/home
fi
if [[ -n ${VAR_PART} ]]; then
  mkdir -p /mnt/var
  mount ${VAR_PART} /mnt/var
fi
if [[ -n ${EFI_PART} ]]; then
  mkdir -p /mnt/boot
  mount ${EFI_PART} /mnt/boot
fi

basic_packages=(
  "zsh"
  "tmux"
  "git"
  "openssh"
  "rsync"
  "sshfs"
  "neovim"
  "gvim"
  "python"
  "python-pip"
  "python-neovim"
  "htop"
  "exa"
  "ripgrep"
  "the_silver_searcher"
)

programming_packages=(
  "nodejs" "npm" "yarn"
  "rust"
  "go" "go-tools"
)

python_packages=(
  "ipython"
  "python-numpy" "python-scipy"
  "python-matplotlib" "python-scikit-learn"
  "python-pillow"
)

nvidia_packages=("nvidia" "cuda" "cudnn" "cudnn6")

printer_packages=("cups" "hplip")
gui_packages=("gnome" "gnome-tweak-tool" "system-config-printer")
font_packages=(
  "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji"
  "adobe-source-code-pro-fonts"
)
app_packages=("firefox")

all_packages=(
  ${basic_packages[@]}
  ${programming_packages[@]}
  ${python_packages[@]}
  ${nvidia_packages[@]}
  ${printer_packages[@]}
  ${gui_packages[@]}
  ${font_packages[@]}
  ${app_packages[@]}
  "intel-ucode"
)

pacstrap /mnt base base-devel ${all_packages[@]}
genfstab -U /mnt | sed -e 's/relatime/noatime/g' >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/tmp/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh pacaur.sh $SCRIPT_DIR
arch-chroot /mnt bash /tmp/scripts/chroot.sh

umount -R /mnt
reboot
