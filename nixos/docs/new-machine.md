# Installing A New Machine With nixos-anywhere

This procedure provisions a new x86_64 machine when its hardware configuration
and SOPS host identity do not exist yet. It uses `nixos-anywhere` to generate
the hardware configuration on the target and Disko to erase and install it.

Do not run this against a machine that contains data to keep. Disko destroys
the disk declared by the host configuration.

## 1. Create The Host Configuration

From `nixos/`, create `modules/machines/<hostname>/default.nix`,
`disk-config.nix`, and `secrets.nix`. Use `night-crawler` as the desktop and
encrypted-root example, or `abiss-watcher` for a server. The host module must
import `./hardware-configuration.nix` even though that file does not exist
yet; `nixos-anywhere` creates it before evaluating the final installation.

Add the host to `flake.nix`:

```nix
nixosConfigurations.<hostname> = mkHost {
  modules = [ ./modules/machines/<hostname> ];
};
```

Set `disk-config.nix` to a stable `/dev/disk/by-id/...` path, never `/dev/sdX`
or `/dev/nvmeXnY`. The actual identifier is collected in step 4. A disk
declaration with LUKS should accept its passphrase through a temporary file,
as in the `night-crawler` example:

```nix
passwordFile = "/tmp/disko-password";
```

## 2. Create The SOPS Host Identity

SOPS secrets are decrypted by the installed machine's SSH host key. Generate
that key before installation, encrypt the new host's secrets to its age
recipient, and copy the private key only during installation. Never commit the
private key or its staging directory.

On the deployment machine, create a restricted staging directory outside the
repository and generate an ED25519 host key:

```bash
host=<hostname>
stage=$(mktemp -d)
mkdir -p "$stage/etc/ssh"
ssh-keygen -q -t ed25519 -N '' \
  -f "$stage/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$stage/etc/ssh/ssh_host_ed25519_key"
nix shell nixpkgs#ssh-to-age -c ssh-to-age \
  < "$stage/etc/ssh/ssh_host_ed25519_key.pub"
```

Copy the displayed `age1...` recipient into the host's rule in `.sops.yaml`,
alongside the administrator recovery recipient. Create the host secret file
with `sops`, including a password hash rather than a plaintext password:

```bash
mkpasswd -m yescrypt
sops "secrets/$host.yaml"
```

Set the generated hash as `ruan-password-hash`. Configure the host's
`secrets.nix` to use that file and the installed SSH host key:

```nix
{
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../../secrets/<hostname>.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets.ruan-password-hash.neededForUsers = true;
  };

  users.mutableUsers = false;
  users.users.ruan.hashedPasswordFile = config.sops.secrets.ruan-password-hash.path;
}
```

Keep an encrypted offline backup of `$stage/etc/ssh/ssh_host_ed25519_key`.
Losing it does not lose the data, but prevents the machine from decrypting
secrets encrypted only for that recipient. Remove `$stage` after confirming
the first boot succeeds.

## 3. Validate Before Erasing A Disk

Commit the configuration and encrypted SOPS file, but not the staged private
key. From `nixos/`, validate the flake. `path:` includes newly generated or
uncommitted files while developing.

```bash
nix flake check --no-build "path:$PWD"
nix build "path:$PWD#nixosConfigurations.<hostname>.config.system.build.toplevel"
```

Because the host imports a hardware file that does not exist yet, initial
evaluation can fail with a missing-file error. In that case, review the host
module, Disko layout, and secrets manually and continue to step 5.
`nixos-anywhere` generates that file before evaluating the final installation.
Run both validation commands after it has been generated.

## 4. Boot And Inspect The Target

Boot the target from a current NixOS installer USB using a wired network. In
the installer terminal, set the password for the `nixos` user and record the
address and disk identifiers:

```bash
passwd
ip addr
lsblk -e7 -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,TYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Update `disk-config.nix` with the chosen `/dev/disk/by-id/...` value and
review it a second time. This is intentionally manual: no installer command
can know which disk is safe to erase.

The installer SSH server is already running. From the deployment machine,
confirm access before proceeding:

```bash
ssh nixos@<installer-ip>
```

## 5. Install

From the `nixos/` directory on the deployment machine, supply the LUKS
passphrase from a protected temporary file and invoke `nixos-anywhere`. The
hardware configuration is written into the repository path given to
`--generate-hardware-config`; review and commit it after installation.

```bash
umask 077
passfile=$(mktemp)
read -r -s -p 'LUKS passphrase: ' luks_passphrase; printf '\n'
unset luks_passphrase

nix run github:nix-community/nixos-anywhere -- \
  --flake "path:$PWD#<hostname>" \
  --target-host "nixos@<installer-ip>" \
  --generate-hardware-config nixos-generate-config \
    "./modules/machines/<hostname>/hardware-configuration.nix" \
  --extra-files "$stage" \
  --disk-encryption-keys /tmp/disko-password "$passfile"

rm -f "$passfile"
```

`--extra-files` places the staged key at
`/etc/ssh/ssh_host_ed25519_key` in the installed system. The machine can then
decrypt its SOPS file during activation. The `--disk-encryption-keys` option
makes the LUKS passphrase available only to Disko in the installer environment.

If SSH uses a key instead of the installer password, add
`-i /path/to/installer-access-key` to the `nixos-anywhere` command. For a
non-installer Linux target, it must be reachable over SSH as `root` or a user
with passwordless `sudo`; `nixos-anywhere` will kexec into its installer.

## 6. Verify And Finish

After the target reboots, remove its old SSH host-key entry if applicable, then
connect using the access configured by the new system:

```bash
ssh-keygen -R <installer-ip>
ssh <user>@<new-host-address>
sudo test -s /run/secrets/ruan-password-hash
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#<hostname>
```

Check `journalctl -b -u sops-nix`, the encrypted root unlock, networking, and
the expected user login. Review and commit the generated
`hardware-configuration.nix`; keep generated detection there and place
reusable graphics or driver policy in a separate host module.

Finally, securely remove the temporary passphrase file and staging directory:

```bash
rm -f "$passfile"
rm -rf "$stage"
```
