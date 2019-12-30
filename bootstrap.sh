#! /bin/zsh -e

# NOTE: you must connect to the internet and partition your disk
# before running this script

# NOTE: you must change the following lines...
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

# ensure the system clock is accurate
timedatectl set-ntp true

# NOTE: PLEASE EDITING THE FOLLOWING AND PICK PACKAGES YOU NEED ###

kernel_packages=(
  "linux"
  #"linux-lts"
  #"linux-zen"
  #"linux-hardened"
  "linux-firmware"
  #"mkinitcpio"
  #"dracut"  # may replace mkinitcpio in the future
)

fs_packages=(
  "xfsprogs"
  #"dosfstools"
  #"exfat-utils"
  #"ntfs-3g"
  #"reiserfsprogs"
  #"jfsutils"
  #"nfs-utils"
)

basic_packages=(
  "man-db"
  "man-pages"
  "usbutils"
  "which"
  "pacman-contrib"
  "python"
  "python-pip"
  #### editor ####
  #"gvim"
  #"vim"
  "neovim"
  "python-pynvim"
  "xsel"
  #### network related ####
  "bind-tools"
  "wget"
  #"netctl"
  #"inetutils"
)

shell_packages=(
  # NOTE: because chroot.sh is written for zsh... please install it.
  # if you don't like it, you need to modify chroot.sh by yourself.
  "zsh"
  "zsh-completions"
  "tmux"
  "git"
  "rsync"
  #### ssh ####
  "openssh"
  "sshfs"
  #"sshpass"
  #### monitor ####
  "htop"
  "iotop"
  "bmon"
  #### utils ####
  "fzf"
  "diff-so-fancy"
  "zsh-syntax-highlighting"
  "exa"      # ls   replacement
  "ripgrep"  # grep replacement
  #"the_silver_searcher"
  "fd"       # find replacement
  "bat"      # cat with wings
  "jq"       # json command line parser
  "hq"       # html command line parser
  "thefuck"
  "tree"

  "chezmoi"  # manage dotfiles
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

nvidia_packages=(
  # NOTE: Please read https://wiki.archlinux.org/index.php/NVIDIA
  "nvidia"
  #"nvidia-lts"
  #"nvidia-dkms"
  "cuda" "cudnn" "nccl"
)

printer_packages=(
  "cups"
  "hplip" # for hp printer
)

# following are what I usually install on a desktop/laptop
gui_packages=(
  "gnome" "gnome-tweak-tool" "system-config-printer"
  "materia-gtk-theme"
  "tilix" # a great terminal emulator
  "firefox"
  "chrome-gnome-shell"
  "gimp"
  "zathura" "zathura-pdf-poppler" "zathura-djvu" "zathura-ps"
  #### input methods ####
  "ibus-kkc"
  "ibus-rime"
)
font_packages=(
  "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji"
  "adobe-source-code-pro-fonts"
)

# NOTE: please check the following

all_packages=(
  ${kernel_packages[@]}
  ${fs_packages[@]}
  ${basic_packages[@]}
  ${shell_packages[@]}
  ${programming_packages[@]}
  ${python_packages[@]}
  #${nvidia_packages[@]}
  ${printer_packages[@]}
  ${gui_packages[@]}
  ${font_packages[@]}
)

MIRRORLIST=/etc/pacman.d/mirrorlist
MIRRORALL=/etc/pacman.d/mirrorlist.all
mv $MIRRORLIST $MIRRORALL
# NOTE: these are mirrors in Taiwan, you may want to change these lines
grep tku $MIRRORALL >> $MIRRORLIST
grep nctu $MIRRORALL >> $MIRRORLIST
grep yzu $MIRRORALL >> $MIRRORLIST
grep ntou $MIRRORALL >> $MIRRORLIST

# NOTE: if you don't want to install base-devel, then you can remove it.
pacstrap /mnt base base-devel ${all_packages[@]}
# NOTE: using relatime or noatime depends on what fs you use...
#genfstab -U /mnt | sed -e 's/relatime/noatime/g' >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh $SCRIPT_DIR
arch-chroot /mnt zsh /scripts/chroot.sh $ROOT_PART

rm -r /mnt/scripts

umount -R /mnt
reboot
