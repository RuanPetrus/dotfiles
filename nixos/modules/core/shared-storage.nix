{ config, ... }:
let
  host = config.dotfiles.host;
in
{
  users.groups.${host.mediaGroup} = { };
  users.users.${host.primaryUser}.extraGroups = [ host.mediaGroup ];

  systemd.tmpfiles.rules = [
    "d ${host.dataRoot} 2775 root ${host.mediaGroup} - -"
    "a+ ${host.dataRoot} - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
  ];
}
