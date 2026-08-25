# NixOS configuration

This directory contains the flake-based NixOS configuration for
`abiss-watcher`, an `x86_64-linux` media server. The host uses Nixarr for the
media stack, SOPS for encrypted secrets, declarative native and Docker
services, and shared ACLs for access to `/data`.

## Repository layout

```text
.
├── flake.nix
├── flake.lock
├── .sops.yaml
├── docs/
│   └── new-machine.md
├── secrets/
│   └── abiss-watcher.yaml
└── modules/
    ├── core/
    │   ├── host.nix
    │   └── shared-storage.nix
    ├── desktops/
    │   └── sway.nix
    ├── hardware/
    │   └── intel-graphics.nix
    ├── machines/abiss-watcher/
    │   ├── default.nix
    │   ├── hardware-configuration.nix
    │   ├── networking.nix
    │   ├── secrets.nix
    │   └── storage.nix
    ├── machines/night-crawler/
    │   ├── disk-config.nix
    │   └── README.md
    ├── services/
    │   ├── backup.nix
    │   ├── docker.nix
    │   ├── homepage-dashboard.nix
    │   ├── immich.nix
    │   ├── media.nix
    │   ├── mpd.nix
    │   ├── syncthing.nix
    │   └── tailscale.nix
    ├── system/default.nix
    └── users/ruan/
        ├── desktop.nix
        ├── default.nix
        ├── home.nix
        └── server.nix
```

The host module is the composition point. It imports the reusable modules and
sets the typed `dotfiles.host` options consumed by them. Machine hardware,
network policy, secrets, and the selected service set stay under
`modules/machines/<hostname>`.

Generated `hardware-configuration.nix` files contain only detected boot and
device facts. Reusable driver policy belongs under `modules/hardware`, while
manually managed host mounts belong in that machine's `storage.nix` or Disko
declaration.

## Adding A Host

Create `modules/machines/<hostname>/default.nix` and set the machine facts:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ../../core/host.nix
    ../../core/shared-storage.nix
    ../../system
    ../../users/<user>
    # Import only the service modules this host should run.
  ];

  dotfiles.host = {
    name = "<hostname>";
    lanAddress = "192.168.1.10";
    dataRoot = "/data";
    primaryUser = "<user>";
    accelerationDevices = [ ];
    accelerationGroups = [ ];
  };
}
```

Add the host to `flake.nix` through the shared constructor:

```nix
nixosConfigurations.<hostname> = mkHost {
  system = "x86_64-linux"; # Optional; this is the default.
  modules = [ ./modules/machines/<hostname> ];
};
```

Generate and review that machine's `hardware-configuration.nix` on the target
hardware. Give each host its own SOPS file and age recipient rather than
sharing SSH host private keys. Validate it with
`nix flake check --no-build "path:$PWD"` before installation.

For a complete first-install procedure, including automatic hardware detection,
SOPS host-key bootstrapping, Disko, and `nixos-anywhere`, see
[`docs/new-machine.md`](docs/new-machine.md).

## Home Manager

Home Manager is integrated as a NixOS module and manages `ruan`'s user-level
configuration. System account settings remain in
`modules/users/ruan/default.nix`. Shared programs and dotfiles belong in
`modules/users/ruan/home.nix`; `server.nix` and `desktop.nix` contain explicit
host-role additions selected by each machine module.

Git is currently managed by Home Manager with:

- Name: `RuanPetrus`
- Email: `xastroboyx11@gmail.com`
- Safe repository: `/srv/palworld-server`

Home Manager generates `~/.config/git/config`. Do not edit that symlink
directly; change `programs.git.settings` in `home.nix` and rebuild the system.
The previous unmanaged configuration is preserved at
`~/.gitconfig.pre-home-manager` and can be removed after confirming the managed
configuration is correct.

As with the NixOS state version, do not update `home.stateVersion` as part of a
normal package update.

## Building the system

Run commands from this directory.

Check the configuration without building the system closure:

```bash
nix flake check --no-build "path:$PWD"
```

Build and activate permanently:

```bash
sudo nixos-rebuild switch --flake "path:$PWD#abiss-watcher"
```

Test a generation without making it the boot default:

```bash
sudo nixos-rebuild test --flake "path:$PWD#abiss-watcher"
```

Using a `path:` flake includes untracked files while developing and avoids the
Git dirty-tree warning. Once all files are committed, `.#abiss-watcher` also
works.

Update all pinned inputs, inspect the resulting `flake.lock`, and rebuild:

```bash
nix flake update
nix flake check --no-build "path:$PWD"
sudo nixos-rebuild switch --flake "path:$PWD#abiss-watcher"
```

Roll back to the previous generation if activation causes a problem:

```bash
sudo nixos-rebuild switch --rollback
```

Do not change `system.stateVersion` as part of a normal package update.

## Host assumptions

- Hostname: `abiss-watcher`
- LAN address: `192.168.15.3`, defined once as `dotfiles.host.lanAddress` in
  `modules/machines/abiss-watcher/default.nix`
- Time zone: `America/Sao_Paulo`
- Boot loader: systemd-boot
- Kernel: latest kernel available from the pinned Nixpkgs
- Network management: NetworkManager
- DNS servers: `1.1.1.1` and `8.8.8.8`
- Root filesystem, boot filesystem, swap, and `/data` are declared in
  `hardware-configuration.nix` by UUID.

The LAN address is used by service listeners, Homepage links, MPD clients, and
the Tailscale advertised route, but a static address is not declared by this
repository. Keep the DHCP lease reserved in the router or update the host
option if the address changes.

## Services

| Service | LAN URL or port | Management |
| --- | --- | --- |
| Homepage | `http://192.168.15.3:8082` | Declarative |
| Jellyfin | `http://192.168.15.3:8096` | Nixarr; libraries are manual |
| Seerr | `http://192.168.15.3:5055` | Nixarr; integrations are manual |
| Radarr | `http://192.168.15.3:7878` | Nixarr and settings-sync |
| Sonarr | `http://192.168.15.3:8989` | Nixarr and settings-sync |
| Lidarr | `http://192.168.15.3:8686` | Nixarr; some setup is manual |
| Bazarr | `http://192.168.15.3:6767` | Nixarr and settings-sync |
| Prowlarr | `http://192.168.15.3:9696` | Nixarr and settings-sync |
| Transmission | `http://192.168.15.3:9091` | Nixarr and settings-sync |
| Calibre server | `http://192.168.15.3:8080` | Declarative |
| Immich | `http://192.168.15.3:2283` | Declarative native NixOS service |
| Samba | TCP `139`, `445`; UDP `137`, `138` | Declarative service; account password is manual |
| Syncthing | `http://192.168.15.3:8384`; TCP/UDP `22000`; UDP `21027` | Declarative service; pairing is manual |
| SSH | TCP `22` | Declarative |
| Docker | Local daemon | Declarative daemon; containers are separate |
| Portainer | `https://192.168.15.3:9443` | Declarative OCI container |
| Recyclarr | No web UI | Declarative daily synchronization |
| Restic documents backup | No web UI | Declarative daily encrypted Dropbox backup |
| MPD | TCP `6600`; stream `http://192.168.15.3:8000` | Declarative shared music queue |
| Tailscale | UDP `41641` | Declarative daemon; account enrollment is manual |

Transmission also exposes TCP and UDP `51413` for peers. UDP `8211` is open
for the externally managed Palworld server. Palworld is not deployed by this
NixOS configuration; only its port and Samba path are present.

## Media automation

`modules/services/media.nix` declaratively manages the supported Nixarr
integrations:

- Prowlarr creates LimeTorrents, Nyaa.si, and The Pirate Bay indexers.
- Prowlarr connects to Sonarr, Radarr, and Lidarr.
- Sonarr and Radarr use Transmission at `localhost:9091`.
- Sonarr uses Transmission category `tv-sonarr`.
- Radarr uses Transmission category `radarr`.
- Bazarr connects to Sonarr and Radarr.
- Recyclarr synchronizes quality definitions, profiles, and custom formats
  daily.

Recyclarr creates these profiles:

- Radarr: `HD Bluray + WEB`
- Sonarr: `WEB-1080p`
- Sonarr: `[Anime] Remux-1080p`

Recyclarr does not assign profiles to titles. Assign regular series to
`WEB-1080p`, anime to `[Anime] Remux-1080p`, and movies to
`HD Bluray + WEB`. Configure the same defaults in Seerr for new requests.

The Arr services allow unauthenticated API calls only from local addresses so
Nixarr can synchronize settings. Requests from other machines still use each
application's configured authentication.

### Manual media configuration

The following settings are not fully managed by the current Nixarr modules:

- Complete the Jellyfin setup wizard and create its administrator account.
- Add Jellyfin libraries from `/data/media/library`.
- Connect Seerr to Jellyfin, Sonarr, and Radarr, then select the Recyclarr
  quality profiles as its defaults.
- Add `/data/media/library/shows` as Sonarr's root folder.
- Add `/data/media/library/movies` as Radarr's root folder.
- Add `/data/media/library/music` as Lidarr's root folder.
- Configure Lidarr's download client; this Nixarr revision only synchronizes
  Transmission automatically for Sonarr and Radarr.
- Select Bazarr subtitle providers and provide any provider credentials.
- Add and monitor titles in Sonarr, Radarr, and Lidarr.
- Set up a Samba password with `sudo smbpasswd -a ruan`. The Unix password and
  Samba password database are separate.
- Deploy and maintain Palworld separately if it is required.

Application state survives rebuilds under `/data/media/.state/nixarr`. A NixOS
rebuild does not reset settings that remain manual.

## Syncthing

Syncthing runs as the dedicated `syncthing` system user with primary group
`media`. Its default shared data directory is `/data/syncthing`. Transfer,
local-discovery, and administration ports are open to the LAN. Browse to
`http://192.168.15.3:8384` to exchange device IDs, add remote devices, and
configure folders. Devices and folders are intentionally not overridden by
NixOS, so UI changes survive rebuilds.

Do not forward port `8384` to the internet. Configure a GUI username and
password before allowing access from any untrusted network.

The recommended general-purpose folder path is `/data/syncthing`. Syncthing
also has group access to the shared media trees, but do not synchronize
`/data/media/.state/nixarr` because it contains live databases and secrets.

Useful commands:

```bash
systemctl status syncthing
journalctl -u syncthing --no-pager -n 100
```

## MPD

MPD indexes `/data/media/library/music` and provides one shared playback queue
on the LAN. Configure an MPD client with server `192.168.15.3` and port `6600`,
then listen to the 192 kbps MP3 stream at:

```text
http://192.168.15.3:8000
```

The control and stream ports are not authenticated and must not be forwarded
to the internet. Suitable clients include M.A.L.P. on Android and Cantata or
ncmpcpp on Linux. Refresh the library and inspect the service with:

```bash
mpc --host 192.168.15.3 update
mpc --host 192.168.15.3 status
systemctl status mpd
journalctl -u mpd --no-pager -n 100
```

## Tailscale

Tailscale provides private remote access without forwarding service ports on
the router. After the first rebuild, enroll the server interactively and
advertise only its existing LAN address:

```bash
sudo tailscale up \
  --accept-dns=false \
  --hostname=abiss-watcher \
  --advertise-routes=192.168.15.3/32
```

Approve the advertised route in the Tailscale administration console. Linux
clients must run `sudo tailscale set --accept-routes=true`; Android accepts
approved subnet routes automatically. This keeps existing service URLs working
remotely without exposing the rest of the home network.

## Storage and permissions

Important paths:

| Path | Purpose |
| --- | --- |
| `/data/media/library` | Nixarr-managed media libraries |
| `/data/media/torrents` | Transmission downloads |
| `/data/media/.state/nixarr` | Private application databases and API keys |
| `/data/Library` | Calibre library |
| `/data/documents` | Documents backed up to Dropbox with Restic |
| `/data/games` | Shared game data |
| `/data/syncthing` | General Syncthing data |

Shared content uses the `media` group, setgid directories, and default POSIX
ACLs. This allows `ruan`, Samba, Jellyfin, Calibre, Transmission, and the Arr
services to read and modify shared files even when a service uses a restrictive
umask.

Do not recursively grant access to `/data/media/.state/nixarr`. Per-service
state directories contain API keys, databases, and other private data. Only
the state parent directories are shared for traversal.

Useful permission checks:

```bash
getent group media
getfacl -p /data/media/library
getfacl -p /data/media/torrents
```

## Secrets with SOPS

Encrypted secrets are committed in `secrets/abiss-watcher.yaml`. The file can
only be decrypted with an age identity matching the public recipient in
`.sops.yaml`.

This host derives its age identity from:

```text
/etc/ssh/ssh_host_ed25519_key
```

Back up that private host key securely and never commit it. A reinstalled host
cannot decrypt the repository's secrets unless the same key is restored or a
new recipient is added before reinstalling.

### Editing secrets

From this directory, open the encrypted file with the host identity:

```bash
nix shell nixpkgs#sops nixpkgs#ssh-to-age -c bash -c '
  export SOPS_AGE_KEY="$(sudo ssh-to-age \
    -private-key \
    -i /etc/ssh/ssh_host_ed25519_key)"
  exec sops secrets/abiss-watcher.yaml
'
```

Add flat YAML keys in the decrypted editor, for example:

```yaml
ruan-password-hash: existing-hash
private-indexer-api-key: secret-value
service-password: secret-value
```

Saving the editor encrypts all values again. Confirm that the file is still
encrypted before committing:

```bash
nix shell nixpkgs#sops -c sops filestatus secrets/abiss-watcher.yaml
```

The result must contain `"encrypted":true`.

### Declaring a secret

Declare the key in `modules/machines/abiss-watcher/secrets.nix`:

```nix
sops.secrets.service-password = {
  owner = "service-user";
  group = "service-group";
  mode = "0400";
};
```

Consume the generated runtime path through a service's file option:

```nix
services.some-service.passwordFile =
  config.sops.secrets.service-password.path;
```

The decrypted file will exist at `/run/secrets/service-password`. Prefer
options named `passwordFile`, `tokenFile`, `apiKeyFile`, or `credentialsFile`.
Never use `builtins.readFile` on a secret or interpolate a secret value into a
normal Nix option, because that can copy plaintext into the world-readable Nix
store.

For a service that requires an environment file, use a runtime SOPS template:

```nix
sops.templates."service.env" = {
  content = ''
    API_KEY=${config.sops.placeholder.private-indexer-api-key}
  '';
  owner = "service-user";
  mode = "0400";
};

services.some-service.environmentFile =
  config.sops.templates."service.env".path;
```

### Changing the login password

`users.mutableUsers = false`, so `passwd` changes are overwritten by the next
activation. Generate a new yescrypt hash, place the hash in
`ruan-password-hash` with SOPS, and rebuild:

```bash
nix shell nixpkgs#whois -c mkpasswd -m yescrypt
sudo nixos-rebuild switch --flake "path:$PWD#abiss-watcher"
```

Do not store the plaintext password in the encrypted YAML when a service can
use a password hash.

### Adding another age recipient

Add the recipient's public `age1...` key to `.sops.yaml`, then edit or update
the keys on `secrets/abiss-watcher.yaml` while an existing identity is
available. Verify decryption before removing an old recipient.

## Backups

`modules/services/backup.nix` backs up `/data/documents` to the encrypted Restic
repository at `dropbox:backups/abiss-watcher/documents`. Dropbox receives only
Restic's encrypted repository data; document contents and names are not visible
there. The backup runs daily around `03:00`, keeps 7 daily, 5 weekly, 12 monthly,
and 3 yearly snapshots, and checks 5 percent of repository data after each run.

The Restic password and rclone configuration are stored in
`secrets/abiss-watcher.yaml` and materialized as root-only files by SOPS. Keep an
independent copy of the Restic password in a password manager. The encrypted
repository cannot be restored without it.

Display the password for transfer to the password manager without creating
another plaintext file:

```bash
sudo cat /run/secrets/restic-password
```

Useful commands:

```bash
systemctl status restic-backups-documents.timer
sudo systemctl start restic-backups-documents.service
sudo journalctl -u restic-backups-documents.service --no-pager -n 100
sudo restic-documents snapshots
```

Restore the latest snapshot to a temporary directory before replacing live
files:

```bash
sudo mkdir -p /tmp/restic-restore
sudo restic-documents restore latest --target /tmp/restic-restore
```

The generated `restic-documents` wrapper supplies the repository, password,
and rclone configuration declared by NixOS.

At minimum, back up:

- This Git repository, including the encrypted SOPS file.
- `/etc/ssh/ssh_host_ed25519_key` in a secure location.
- `/data/media/.state/nixarr` for media application databases and generated
  API keys.
- `/data/media/library`, `/data/media/torrents`, and `/data/Library` according
  to the desired media retention policy.
- `/var/lib/samba/private` if the Samba account database must be preserved.
- Docker volume `portainer_portainer_data` and `/data/immich` according to the
  desired retention policy; neither is included in the Restic documents backup.
- State for manually managed Docker containers and Palworld.

The encrypted SOPS file without its private age identity is not recoverable.

## Troubleshooting

Check failed system units:

```bash
systemctl --failed
```

Inspect an application:

```bash
systemctl status jellyfin
journalctl -u jellyfin --no-pager -n 100
```

Nixarr synchronization units:

```bash
systemctl status prowlarr-sync-config
systemctl status sonarr-sync-config
systemctl status radarr-sync-config
systemctl status bazarr-sync-config
```

Recyclarr is a oneshot service, so `inactive (dead)` after a successful run is
normal. Its timer should be active:

```bash
systemctl status recyclarr.timer
journalctl -u recyclarr --no-pager -n 100
sudo systemctl start recyclarr
```

Samba uses NixOS-specific unit names:

```bash
systemctl status samba-smbd samba-nmbd
```

Check listeners and firewall configuration:

```bash
ss -ltn
nix eval --json \
  "path:$PWD#nixosConfigurations.abiss-watcher.config.networking.firewall.allowedTCPPorts"
```

## Security notes

- SSH password authentication is currently enabled.
- `ruan` currently has passwordless sudo for all commands.
- Media web interfaces listen on LAN-accessible addresses and their ports are
  opened by the firewall.
- The dashboard includes links to HTTP services without TLS.
- SOPS protects secrets at rest in Git, but decrypted runtime files remain
  accessible to their configured owner, group, and root.

Review these choices before exposing the host beyond a trusted LAN.
