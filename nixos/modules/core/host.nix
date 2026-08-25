{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.host;
in
{
  options.dotfiles.host = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Machine hostname.";
    };

    lanAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional LAN address used by server services and local clients.";
    };

    dataRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional root directory for persistent shared data.";
    };

    primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "Primary interactive user for this machine.";
    };

    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "Group used for shared media and data access.";
    };

    accelerationDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Hardware acceleration devices exposed to media services.";
    };

    accelerationGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Supplementary groups used to access acceleration devices.";
    };
  };

  config = {
    networking.hostName = cfg.name;

    assertions = [
      {
        assertion = cfg.dataRoot == null || lib.hasPrefix "/" cfg.dataRoot;
        message = "dotfiles.host.dataRoot must be an absolute path";
      }
    ];
  };
}
