# Default packages Arch Linux

## Basic for building software
```sh
sudo pacman -S git base-devel curl cmake unzip ninja tree-sitter
```

## YAY
```sh
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## ZSH
Installing and making default shell
```sh
yay -S zsh
chsh -s /usr/bin/zsh
```

Configuring  
If you not have clone config repository to home directory
```sh
git clone https://github.com/RuanPetrus/dotfiles 
```
Creating zsh config  
```sh
mkdir -p ~/.config/zsh
cp -r ~/dotfiles/zsh ~/.config/
```

## Rust utilities
Link to other utilities [Rewritten in rust](https://zaiste.net/posts/shell-commands-rust/)
```sh
cargo install bat exa fd ripgrep 
```

## Power level 10k
```sh
yay -S --noconfirm zsh-theme-powerlevel10k-git  
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc  
```

## Neovim
Installing neovim  
```sh
git clone https://github.com/neovim/neovim
cd neovim
git checkout release-0.7
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

Installing plugin dependencies
```sh
pip install pynvim
pip intall black
npm install -g neovim
```
