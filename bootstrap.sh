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
  "zsh-completions"
  "tmux"
  "git"
  "openssh"
  "sshfs"
  #"sshpass"
  "rsync"
  "python"
  "python-pip"
  # editor
  "gvim"
  #"vim"
  "xsel"
  "neovim"
  "python-neovim"
  # monitor
  "htop"
  "iotop"
  "bmon"
  # network related
  "bind-tools"
  "wget"
)

utils_packages=(
  "fzf"
  "diff-so-fancy"
  "zsh-syntax-highlighting"
  "exa"      # ls   replacement
  "ripgrep"  # grep replacement
  "fd"       # find replacement
  "bat"      # cat with wings
  "jq"       # json command line parser
  "hq"       # html command line parser
  "thefuck"
  #"tree"
  #"the_silver_searcher"
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

nvidia_packages=("nvidia" "cuda" "cudnn" "nccl")

font_packages=(
  "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji"
  "adobe-source-code-pro-fonts"
)
printer_packages=("cups" "hplip")
im_packages=(
  "ibus-kkc"
  "ibus-rime"
)
gui_packages=(
  "gnome" "gnome-tweak-tool" "system-config-printer"
  #"materia-gtk-theme"
  "tilix" # a great terminal emulator
  "firefox"
  "chrome-gnome-shell"
  "gimp"
  #"zathura" "zathura-pdf-poppler" "zathura-djvu" "zathura-ps"
  ${im_packages[@]}
)
fs_packages=(
  "dosfstools"
  "exfat-utils"
  "ntfs-3g"
)

all_packages=(
  ${basic_packages[@]}
  ${utils_packages[@]}
  ${programming_packages[@]}
  ${python_packages[@]}
  ${nvidia_packages[@]}
  ${font_packages[@]}
  ${printer_packages[@]}
  ${gui_packages[@]}
  ${fs_packages[@]}
)

MIRRORLIST=/etc/pacman.d/mirrorlist
MIRRORALL=/etc/pacman.d/mirrorlist.all
mv $MIRRORLIST $MIRRORALL
grep tku $MIRRORALL >> $MIRRORLIST
grep nctu $MIRRORALL >> $MIRRORLIST
grep yzu $MIRRORALL >> $MIRRORLIST
grep ntou $MIRRORALL >> $MIRRORLIST

pacstrap /mnt base base-devel ${all_packages[@]}
genfstab -U /mnt | sed -e 's/relatime/noatime/g' >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh $SCRIPT_DIR
arch-chroot /mnt bash /scripts/chroot.sh

rm -r /mnt/scripts

umount -R /mnt
reboot
