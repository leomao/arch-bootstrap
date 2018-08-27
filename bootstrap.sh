#! /bin/zsh -e

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
  "pacman-contrib"
  "zsh"
  "tmux"
  "git"
  "openssh"
  "rsync"
  "sshfs"
  "neovim"
  "python"
  "python-pip"
  "python-neovim"
  "htop"
  "exa"      # ls   replacement
  "ripgrep"  # grep replacement
  "fd"       # find replacement
  "bat"      # cat with wings
  # "the_silver_searcher"
  #"vim"
  "gvim"
  "xsel"
)

programming_packages=(
  "nodejs" "npm" "yarn"
  "rust"
  "go" "go-tools"
)

python_packages=(
  "ipython"
  # if you want to compile following packages with intel-mkl,
  # comment out following lines and use PKGBUILDs from
  # https://github.com/leomao/arch-PKGBUILDs
  "python-numpy" "python-scipy"
  "python-pillow"
  "python-scikit-learn"
  "python-matplotlib"
  "tk" # matplotlib need it
)

nvidia_packages=("nvidia" "cuda" "cudnn")

printer_packages=("cups" "hplip")
gui_packages=("gnome" "gnome-tweak-tool" "system-config-printer")
font_packages=(
  "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji"
  "adobe-source-code-pro-fonts"
)
app_packages=(
  "firefox"
  "tilix"
)

fs_packages=(
  "dosfstools"
  "exfat-utils"
  "ntfs-3g"
)

all_packages=(
  "intel-ucode"
  ${basic_packages[@]}
  ${programming_packages[@]}
  ${python_packages[@]}
  ${nvidia_packages[@]}
  ${printer_packages[@]}
  ${gui_packages[@]}
  ${font_packages[@]}
  ${app_packages[@]}
  ${fs_packages[@]}
)

MIRRORLIST=/etc/pacman.d/mirrorlist
MIRRORALL=/etc/pacman.d/mirrorlist.all
mv $MIRRORLIST $MIRRORALL
grep nctu $MIRRORALL >> $MIRRORLIST
grep yzu $MIRRORALL >> $MIRRORLIST
grep tku $MIRRORALL >> $MIRRORLIST
grep ntou $MIRRORALL > $MIRRORLIST

pacstrap /mnt base base-devel ${all_packages[@]}
genfstab -U /mnt | sed -e 's/relatime/noatime/g' >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh $SCRIPT_DIR
arch-chroot /mnt bash /scripts/chroot.sh

rm -r /mnt/scripts

umount -R /mnt
reboot
