# Haskell
For haskell i use ghcup
```sh
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

# ASDF
## Installing
Dowload with YAY
```sh
yay -S asdf-vm
```
Add to .zshrc  
```sh
echo "source /opt/asdf-vm/asdf.sh" >> ~/.zshrc
```

## Using
`asdf list` show plugins and language versions installed
`asdf plugin add nodejs` install nodejs plugin  
`asdf list-all nodejs` show all node versions  
`asdf install nodejs 16.13.2`  install especific version
`asdf global nodejs 17.4.0` uses nodejs 17.4.0 as global node  
`asdf local nodejs 17.4.0` per project  

# Python
I use asdf to manage python
```sh
asdf plugin add python
asdf install python 3.10.8
asdf global python 3.10.8
```

# NodeJs
I use asdf to manage node
```sh
asdf plugin add nodejs
asdf install nodejs 18.4.0
asdf global nodejs 18.4.0
```
