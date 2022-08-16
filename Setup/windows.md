# Debloat
[Win-Debloat-Tools](https://github.com/LeDragoX/Win-Debloat-Tools)  

# WSL
O wsl é uma camada de suporte para linux dentro do windows.  

Instale com o comando `wsl --install`  

## Arch
Dowload arch.zip from [ArchWSL](https://github.com/yuk7/ArchWSL)  
Descompacte o zip no C: abra o powersheel e execute o binario 

Set root default password  
`passwd`  

Set user  
``` sh
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
exit
Arch.exe config --default-user <username>
```

Configuring and using Pacman  
```sh
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syy archlinux-keyring
sudo pacman -Syyyu
```

**Install default packages**

# Terminal
Baixe o **Windows Terminal** da loja da microsoft e o utilize como default  

## Temas
Vá em [Windows themes](https://windowsterminalthemes.dev/) e copie o tema para clipboard  
Em configurações do windows terminal e abra o arquivo de configurações  
Cole o novo tema no final (Cuidado para não quebrar o JSON)  

## Fontes
Para user o power level 10k baixe as fontes e instale do site [powerlevel10k](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)  
E configure para utilizar elas  

