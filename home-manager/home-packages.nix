{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Window manager
    libnotify
    user-dmenu

    # Desktop apps
    chromium
    mpv
    stremio
    pavucontrol
    teams-for-linux
    discord
    obsidian
    feh
    flameshot

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
    texliveFull
    python311
  ];
}
