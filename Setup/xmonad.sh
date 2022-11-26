#!/usr/bin/env sh

## Fonts
yay -S adobe-source-code-pro-fonts adobe-source-sans-fonts otf-font-awesome otf-raleway pcmanfm ttf-hack ttf-jetbrains-mono ttf-joypixels ttf-ms-fonts ttf-ubuntu-font-family

##
yay -S ly
sudo systemctl enable ly.service
sudo pacman -S xorg xdotool xmonad xmonad-contrib xmobar conky xterm dmenu alacritty rofi trayer volumeicon zathura yad nitrogen
