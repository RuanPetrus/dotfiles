{
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
  };
}
