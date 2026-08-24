{
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "ruan" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.ruan = import ./home.nix;
  };

  users = {
    users.ruan = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "users"
        "input"
      ];
    };
    groups = {
      ruan = {
        gid = 1000;
      };
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
