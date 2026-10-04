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
    lanAddress = "192.168.0.20";
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
- LAN address: `192.168.0.10`, defined once as `dotfiles.host.lanAddress` in
  `modules/machines/abiss-watcher/default.nix`
- Time zone: `America/Sao_Paulo`
- Boot loader: systemd-boot
- Kernel: latest kernel available from the pinned Nixpkgs
- Network management: NetworkManager
- DNS servers: `1.1.1.1` and `1.0.0.1`
- Root filesystem, boot filesystem, swap, and `/data` are declared in
  `hardware-configuration.nix` by UUID.

The LAN address is used by the static NetworkManager profile, service
listeners, Homepage links, MPD clients, and the Tailscale advertised route.
Update the host option and any cross-machine references together if the
address changes.

## LAN allocation

The LAN uses `192.168.0.0/24`. Infrastructure and machines that need stable
addresses use host-configured static addresses below the DHCP pool.

| Address or range | Purpose |
| --- | --- |
| `192.168.0.0` | Network address |
| `192.168.0.1` | Router and default gateway |
| `192.168.0.2-192.168.0.10` | Network infrastructure, including access points and infrastructure servers |
| `192.168.0.11-192.168.0.99` | Other machines with static addresses |
| `192.168.0.100-192.168.0.254` | Router-managed DHCP pool |
| `192.168.0.255` | Broadcast address |

Current static assignments:

| Host | Address | Role |
| --- | --- | --- |
| Router | `192.168.0.1` | Internet gateway |
| `abiss-watcher` | `192.168.0.10` | Infrastructure server |
| `nameless-king` | `192.168.0.11` | Desktop and game-streaming host |
| `night-crawler` | `192.168.0.12` | Laptop on the home Wi-Fi networks |

Night Crawler's saved `marombinhas` and `marombinhas_5G` NetworkManager
profiles use its static address. Profiles for other Wi-Fi networks continue to
use DHCP.

## Planned router architecture

The router now runs as an autostarting microvm.nix QEMU virtual machine on
`abiss-watcher`. This keeps the router configuration isolated from the media
and storage services while dedicated router hardware is unavailable. It
remains a separate `nixosConfigurations.router` host so it can later move to
dedicated hardware without being disentangled from `abiss-watcher`.

The router VM and the `abiss-watcher` host will still share a physical failure
domain. A host reboot, hardware failure, or power loss will interrupt both the
server and Internet access. Virtualization provides network and configuration
isolation, not router redundancy.

### Physical and virtual topology

The Dell `0H092P` Intel PRO/1000 VT quad-port Gigabit PCIe adapter is passed
through as a complete IOMMU group to the router VM. The existing onboard
interface remains owned by the NixOS host and provides its LAN and management
connection.

```text
ISP 1 (PPPoE) ───── NIC port 1 ─┐
                                 │
ISP 2 (DHCP) ────── NIC port 2 ─┼── NixOS router VM
                                 │        │
LAN switch ───────── NIC port 3 ─┘        │
                                          │ routing, firewall and DNS
LAN switch ───── onboard NIC ── abiss-watcher host

NIC port 4: spare, recovery link, separate network, or additional LAN port
```

Use an external Ethernet switch for machines and access points. Bridging two
router ports is possible, but the NIC and router VM are not intended to replace
a dedicated switch. The router VM will use `192.168.0.1`; `abiss-watcher` will
remain at `192.168.0.10` through its onboard interface.

Do not connect either ISP until PCI passthrough, interface identity, firewall
policy, and physical port ordering have been verified. The interface order
reported by Linux may not match the order printed on the card.

When the NIC is installed, verify it before changing the live network:

```bash
lspci -nnk
ip -brief link
find /sys/kernel/iommu_groups/ -type l
```

Confirm that all four ports use the expected Intel driver, identify their PCI
device IDs, and verify that the complete card has a safe IOMMU group. Enable
Intel VT-d/IOMMU in firmware and the host kernel. Do not use an ACS override as
a security boundary. The full-height card also needs a suitable PCIe slot and
case bracket.

### Router software stack

The planned NixOS router is composed from standard Linux services:

| Responsibility | Planned component |
| --- | --- |
| Physical links, LAN bridge, DHCP WAN, routes and IPv6 | `systemd-networkd` |
| PPPoE session | `services.pppd` |
| Stateful firewall, forwarding, NAT and connection marks | nftables |
| WAN health checks, failover and optional weighted routing | FireHOL `link-balancer` only |
| LAN DHCP | dnsmasq or Kea |
| DNS filtering and local records | AdGuard Home |
| Recursive DNS and DNSSEC validation | Unbound |
| Traffic shaping and bufferbloat control | CAKE with `tc` and IFB devices |
| Runtime credentials | `sops-nix` |
| Remote administration | Tailscale or WireGuard |

FireHOL's full firewall is not planned. Its `link-balancer` executable manages
multi-WAN routes through `iproute2`, while nftables remains the sole owner of
the router firewall and NAT policy. Avoid mixing the generated NixOS firewall,
`networking.nat`, a full FireHOL firewall, and a custom ruleset without an
explicit division of ownership. The standard `networking.nat` module models a
single external interface and is not sufficient for this dual-WAN design.

DNS traffic will follow this path:

```text
LAN clients → AdGuard Home :53 → Unbound on loopback → authoritative DNS
```

AdGuard Home provides filtering, local records, statistics, and its management
UI. Unbound performs recursive resolution, caching, and DNSSEC validation.
Only AdGuard Home should listen on LAN port 53; Unbound should listen on a
different loopback-only port. DNS and DHCP services must bind only to LAN
interfaces, and management interfaces must never be reachable from either WAN.

### Dual-WAN policy

Start with failover instead of load balancing:

- PPPoE is the primary WAN.
- DHCP is the backup WAN.
- Health checks must test multiple Internet destinations through each WAN, not
  only carrier state or the ISP gateway.
- Failure and recovery thresholds must prevent route flapping.
- Existing connections will normally fail when changing ISP because the
  public source address changes.

After failover is stable, weighted per-connection load balancing can be added.
It distributes separate connections between providers; it does not combine
both links into one faster connection. nftables connection marks and separate
routing tables must preserve the selected WAN for return traffic. Inbound port
forwarding and replies received through the backup WAN require the same
symmetric-routing treatment.

Implement IPv4 first. Dual-provider IPv6 requires source-policy routing and
careful delegated-prefix and router-advertisement lifetime handling. It cannot
provide transparent failover between unrelated ISP prefixes, so initial IPv6
service should use one provider until IPv4 behavior is proven.

### Traffic shaping

Configure CAKE independently for each WAN because bandwidth and encapsulation
overhead differ. Upload shaping is attached to the WAN interface; download
shaping uses an IFB interface. PPPoE normally uses an MTU of `1492` and needs
appropriate overhead accounting and, where required, TCP MSS handling.

The CAKE rate should be slightly below measured sustained throughput so queues
form on the router instead of in the modem or ISP network. Because `ppp0` is
recreated after a PPPoE reconnect, a `pppd` or systemd hook must restore its
CAKE configuration. Accurate rates and overhead values must be calibrated on
the real links rather than assumed in VM tests.

### Deployment and recovery

Develop the router as an independent flake host and test it with isolated WAN,
router, and LAN client VMs before connecting physical providers. Tests should
cover DHCP, DNS, NAT, default-deny WAN access, PPPoE, failover in both
directions, recovery, firewall reloads, and loss of each upstream.

Use this implementation order:

1. Validate the NIC, IOMMU group, PCI passthrough, and VM autostart.
2. Configure the LAN and DHCP WAN in an isolated test network.
3. Add PPPoE with credentials supplied by `sops-nix` at runtime.
4. Add the nftables firewall and IPv4 NAT.
5. Prove basic primary/backup routing, then add Internet-aware health checks.
6. Add LAN DHCP, AdGuard Home, and Unbound.
7. Measure both links and configure CAKE.
8. Add weighted load balancing and IPv6 only after the simpler design is
   stable.

The initial independent router host is now implemented under
`modules/machines/router` and exported as `nixosConfigurations.router`. It
provides the isolated-test baseline through LAN DHCP/DNS and IPv4 NAT; see the
[router host README](modules/machines/router/README.md) for interface defaults,
PPPoE activation, and the hardware-dependent work that remains.

`nixos-rebuild build` and `dry-activate` do not interrupt routing. Activating a
generation may restart only the services whose definitions changed, but PPPoE,
interface, route, passthrough, or VM changes can interrupt Internet access.
Router VM or hypervisor reboots cause a complete outage. Use local console
access and a timed automatic rollback that restores the last confirmed
generation unless the new generation is explicitly accepted. Validate
nftables syntax before activation and retain the old physical router as a
rollback path during initial deployment.

## Services

| Service | LAN URL or port | Management |
| --- | --- | --- |
| Homepage | `http://192.168.0.10:8082` | Declarative |
| Jellyfin | `http://192.168.0.10:8096` | Nixarr; libraries are manual |
| Seerr | `http://192.168.0.10:5055` | Nixarr; integrations are manual |
| Radarr | `http://192.168.0.10:7878` | Nixarr and settings-sync |
| Sonarr | `http://192.168.0.10:8989` | Nixarr and settings-sync |
| Lidarr | `http://192.168.0.10:8686` | Nixarr; some setup is manual |
| Bazarr | `http://192.168.0.10:6767` | Nixarr and settings-sync |
| Prowlarr | `http://192.168.0.10:9696` | Nixarr and settings-sync |
| Transmission | `http://192.168.0.10:9091` | Nixarr and settings-sync |
| Calibre server | `http://192.168.0.10:8080` | Declarative |
| Immich | `http://192.168.0.10:2283` | Declarative native NixOS service |
| Samba | TCP `139`, `445`; UDP `137`, `138` | Declarative service; account password is manual |
| Syncthing | `http://192.168.0.10:8384`; TCP/UDP `22000`; UDP `21027` | Declarative service; pairing is manual |
| SSH | TCP `22` | Declarative |
| Docker | Local daemon | Declarative daemon; containers are separate |
| Portainer | `https://192.168.0.10:9443` | Declarative OCI container |
| Recyclarr | No web UI | Declarative daily synchronization |
| Restic documents backup | No web UI | Declarative daily encrypted Dropbox backup |
| MPD | TCP `6600`; stream `http://192.168.0.10:8000` | Declarative shared music queue |
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
`http://192.168.0.10:8384` to exchange device IDs, add remote devices, and
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
on the LAN. Configure an MPD client with server `192.168.0.10` and port `6600`,
then listen to the 192 kbps MP3 stream at:

```text
http://192.168.0.10:8000
```

The control and stream ports are not authenticated and must not be forwarded
to the internet. Suitable clients include M.A.L.P. on Android and Cantata or
ncmpcpp on Linux. Refresh the library and inspect the service with:

```bash
mpc --host 192.168.0.10 update
mpc --host 192.168.0.10 status
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
  --advertise-routes=192.168.0.10/32
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
