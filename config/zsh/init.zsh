zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt AUTO_MENU COMPLETE_IN_WORD

autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f %F{blue}%~%f# '
