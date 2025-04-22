{...}: {
  nixpkgs = {
    overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldattrs: {
          src = fetchGit {
            url = "https://github.com/RuanPetrus/dwm";
            rev = "c90242bbb584d697cd45b338fc728dfeb3523d17";
          };
        });
      })
    ];
  };
  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;
  };
}
