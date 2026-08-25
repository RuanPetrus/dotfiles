{
  config,
  pkgs,
  ...
}:
let
  host = config.dotfiles.host;
in
{
  environment.systemPackages = [ pkgs.docker-compose ];

  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
    };

    oci-containers = {
      backend = "docker";

      containers.portainer = {
        image = "portainer/portainer-ce@sha256:f6bc23d1695530a609563fd65c180aaafec0fc02e019d5fc63d16b6fbe83addd";
        ports = [ "${host.lanAddress}:9443:9443" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_portainer_data:/data"
        ];
      };
    };
  };
}
