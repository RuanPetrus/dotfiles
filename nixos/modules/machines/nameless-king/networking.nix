{
  networking.networkmanager.ensureProfiles.profiles.nameless-king-wired = {
    connection = {
      id = "nameless-king-wired";
      type = "ethernet";
      interface-name = "enp5s0";
      autoconnect = true;
    };
    # NetworkManager's keyfile format represents the magic-packet flag as 64.
    ethernet.wake-on-lan = 64;
    ipv4.method = "auto";
    ipv6.method = "auto";
  };
}
