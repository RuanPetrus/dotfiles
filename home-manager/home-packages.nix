{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    mpv
    pavucontrol
    teams-for-linux

    # CLI utils
    bc
    ffmpeg
    fzf
    htop
    ntfs3g
    mediainfo
    ranger
    ripgrep
    udisks
    unzip
    wget
    yt-dlp
    zip
  ];
}
