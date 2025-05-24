{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    chromium
    mpv
    pavucontrol
    teams-for-linux
    discord
    obsidian
    feh

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

    # Programming
    python311
  ];
}
