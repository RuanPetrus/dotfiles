{...}: {
  nixpkgs = {
    overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldattrs: {
          src = fetchGit {
            url = "https://github.com/RuanPetrus/dwm";
            rev = "0556ce94114738c75b730405539acd5011c61c90";
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
