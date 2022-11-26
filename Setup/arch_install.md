# Archlinux Installation
Load keyboard layout
```zsh
loadkeys br-abnt2
```

## Wifi
Current arch linux iso comes with *iwctl* utility
```zsh
iwctl
station <wifi-adapter> connect <network-name>
exit
```

## Partition
You can use the gdisk utility to partition your disk
```zsh
gdisk /dev/sda
```

Codes:
- EFI: *ef00*

### Format
Format the efi partition with fat 32
```sh
mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/mapper/root
```

### Encryption
You can use crypt to encrypt your partition
```sh
cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/sda2
```
To open the encrypt partition
```sh
cryptsetup luksOpen /dev/sda2 root
```

### Mount
```sh
mount /dev/mapper/root /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
cd
umount /mnt
mount -o noatime,space_cache=v2,compress=zstd,subvol=@ /dev/mapper/root /mnt
mkdir /mnt/{boot,home}
mount -o noatime,space_cache=v2,compress=zstd,subvol=@home /dev/mapper/root /mnt/home
mount /dev/sda1 /mnt/boot
```

## Base system
To install the base system use
```sh
pacstrap /mnt base linux linux-firmware git neovim intel-ucode
```
To create the fstabe of the discs
```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

## Initcpio
Edit */etc/mkinitcpio.conf*, Add *btrfs* to *Modules* and add *encrypt* before *filesystems* in *Hooks*
Recreate with the command
```sh
mkinitcpio -p linux
```

## Base
Clone my repo
```sh
git clone https://github.com/RuanPetrus/dotfiles
```

## Boot
Install systemd boot
```sh
bootctl --path=/boot install
```
Edit */boot/loader/loader.conf*
Put the bellow in there
```conf
timeout 10
default arch
```
Create the arch entry in */boot/loader/entries/arch.conf*
```conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=
```
Get the uuids with *blkid* command
```sh
blkid /dev/sda2 >> /boot/loader/entries/arch.conf
blkid /dev/mapper/root >> /boot/loader/entries/arch.conf
```
Back to configuration file and add de UUIDS

Create the fallback
```sh
cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf
```
Change the initramfs

## exit
```sh
exit
umount -R /mnt
exit
reboot
```
