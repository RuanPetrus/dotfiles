
export PS1="\[\e[31m\][\[\e[m\]\[\e[33m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[36m\]\h\[\e[m\] \[\e[35m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\] "

HISTSIZE= HISTIFILESIZE= #infinit history
set -o vi

alias ls="ls --color"
stty -ixon

# youtube-dl alias
mp3 () {
    yt-dlp --embed-thumbnail --add-metadata -f bestaudio --extract-audio --audio-format best -o '/mnt/media/Music/yt-dl/%(title)s.%(ext)s' "$1"
}

mp3p () {
    yt-dlp --sleep-interval 3 --embed-thumbnail --add-metadata -f bestaudio --extract-audio --audio-format best -o '/mnt/media/Music/yt-dl/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' "$1"
}

export EDITOR="nvim"
export BROWSER="firefox"

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export HISTFILE="${XDG_STATE_HOME}"/bash/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/pythonrc

alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias nvidia-settings=nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings

PATH=$PATH:"$HOME/.local/bin"

. "$CARGO_HOME/env"

alias e=$EDITOR

alias sb="e ~/.local/share/bookmark"
