{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
     git
     neovim 
     stremio
     home-manager
     xclip

     # Build tools
	 gcc
	 gnumake
	 ninja
	 cmake
	 linux
	 autoconf
	 pkg-config
	 automake
  ];
}

