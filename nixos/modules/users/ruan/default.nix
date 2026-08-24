{
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "ruan" ];
  users = {
    users.ruan = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ 
          "wheel" 
          "users" 
          "input" 
	  "data"
          "media"
      ];
    };
    groups = {
      ruan = {
        gid = 1000;
      };
      data = {};
    };
  };
	security.sudo.extraRules = [
	  {
	    users = [ "ruan" ];
	    commands = [
	      {
		command = "ALL";
		options = [ "NOPASSWD" ];
	      }
	    ];
	  }
	];
  programs.zsh.enable = true;
}
