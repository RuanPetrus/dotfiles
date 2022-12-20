#!/bin/sh
#Don't randomly turn off
xset s off
xset -dpms
xset s noblank

# Speedy keys
xset r rate 210 40

# Keyboard
setxkbmap br
setxkbmap -option caps:escape

# Emacs
/usr/bin/emacs --daemon &

# Flameshot
flameshot &
