{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.docker-compose ];

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };
}
