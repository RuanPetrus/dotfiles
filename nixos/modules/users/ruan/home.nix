{
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "RuanPetrus";
        email = "xastroboyx11@gmail.com";
      };
      safe.directory = [ "/srv/palworld-server" ];
    };
  };
}
