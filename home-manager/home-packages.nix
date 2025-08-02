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
    ferdium
    gimp
    calibre

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
    ncftp

    # Programming
    texliveFull
    python311
    ghc
    graphviz

    # Neospace
    slack

    # Rust
    rustup

    emacs
    arandr

    tftp-hpa
    tcpdump
  ];
}
