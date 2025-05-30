(self: super: {
  user-dmenu = super.dmenu.overrideAttrs (oldAttrs: {
    pname = "user-dmenu";
    version = "1.0.0";
    src = /home/ruan/dev/dmenu;
    buildInputs = oldAttrs.buildInputs;
  });
})
