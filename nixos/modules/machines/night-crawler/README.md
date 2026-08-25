# night-crawler bootstrap

`night-crawler` is intentionally not a flake output yet. The reusable Sway
desktop, generated hardware scan, graphics policy, and Disko layout are ready.
An installable host still needs its SOPS identity, login secret, and final host
composition.

## Detected Hardware

- Model: Dell Inspiron 15 3530
- Boot mode: UEFI
- CPU platform: Intel Raptor Lake-P
- Integrated GPU: Intel Iris Xe at `PCI:0:2:0`
- Discrete GPU: NVIDIA GeForce MX550 at `PCI:1:0:0`
- Internal disk: 512 GB SK hynix BC901 NVMe

`hardware-configuration.nix` contains only generated detection. `graphics.nix`
uses Intel as the primary GPU and NVIDIA PRIME offload with fine-grained power
management, while `../../hardware/intel-graphics.nix` provides Intel media and
compute support.

## Disk Layout

`disk-config.nix` declaratively manages the entire disk at:

```text
/dev/disk/by-id/nvme-eui.0000000000000000ace42e00356ca41d
```

The layout contains a 1 GiB EFI system partition and a passphrase-encrypted
LUKS partition named `cryptroot`. The encrypted Btrfs filesystem has separate
subvolumes for `/`, `/home`, `/nix`, `/var/log`, and an 8 GiB swapfile under
`/swap`.

Applying this declaration erases the entire target disk. Before every run,
confirm that the identifier still resolves to the intended drive:

```bash
readlink -f /dev/disk/by-id/nvme-eui.0000000000000000ace42e00356ca41d
lsblk -e7 -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,TYPE,MOUNTPOINTS
```

## Required Inputs

1. Create a host-specific SSH host key and convert its public key with
   `ssh-to-age`.
2. Add that age recipient to `.sops.yaml` for
   `secrets/night-crawler.yaml`.
3. Store `ruan-password-hash` in that encrypted file and add a local
   `secrets.nix` module modeled after the server host.

The future host composition should import:

```nix
{
  imports = [
    ./disk-config.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../core/host.nix
    ../../desktops/sway.nix
    ../../hardware/intel-graphics.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "night-crawler";
    primaryUser = "ruan";
  };

  home-manager.users.ruan.imports = [ ../../users/ruan/desktop.nix ];
}
```

Choose the boot loader and `system.stateVersion` from the actual installation
rather than copying the server values. Once these inputs exist, add the host to
`flake.nix` with `mkHost` and build it before installation.

Only after the complete host builds and secrets are ready, apply the layout
from the NixOS installer environment:

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  ./modules/machines/night-crawler/disk-config.nix
```

Disko will request the initial LUKS passphrase interactively. Continue with
`nixos-install --flake "path:.#night-crawler"` after the filesystems are mounted.
