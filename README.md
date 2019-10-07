# Arch Bootstrap Script

My personal scripts for bootstrapping an archlinux system.  

NOTE: Sometimes I just updated the script without testing it,
please check it by yourself and make sure that you fully understand
the installation process before using it.

# Usage
1. Boot a computer with arch live image.
2. Prepare the partitions for installing the system.
3. Make sure the internet is available.
4. run the following command:
```console
$ curl -L https://git.io/v5Aju | tar -xz --strip-component=1
$ vim bootstrap.sh # set the variables and modify packages to what you need.
$ vim chroot.sh # set the variables to what you need.
$ zsh bootstrap.sh
```
