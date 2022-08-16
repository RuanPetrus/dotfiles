#ASDF

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


## Languages
```sh
asdf plugin add python
asdf plugin add rust
asdf plugin add nodejs
asdf plugin add java
asdf plugin add scala
asdf plugin add golang
asdf plugin add lua
```
