# Router host

This directory implements the independent `nixosConfigurations.router` host.
It currently provides:

- `systemd-networkd` with a static LAN and DHCP backup WAN
- optional primary PPPoE with a lower default-route metric
- an nftables-owned default-deny firewall, forwarding, NAT, and PPPoE MSS clamp
- dnsmasq for LAN DHCP only
- AdGuard Home on the LAN forwarding to loopback-only recursive Unbound
- SSH key authentication through the private management network or LAN

## Virtual machine

`abiss-watcher` runs the router as an autostarting microvm.nix QEMU guest. The
VM has 2 vCPUs, 3 GiB of RAM, a read-only Nix store disk, and a persistent 16
GiB ext4 disk mounted at `/var`. The persistent image is stored at
`/var/lib/microvms/router/router-data.img` on the host.

All four Intel `8086:10e8` functions in IOMMU group 2 are passed through. Guest
names are assigned by permanent MAC address rather than guest PCI enumeration:

| Host PCI address | MAC | Guest name | Status |
| --- | --- | --- | --- |
| `0000:04:00.1` | `00:1b:21:72:dc:d5` | `wan-pppoe` | Verified by carrier |
| `0000:03:00.0` | `00:1b:21:72:dc:d0` | `spare0` | Unused |
| `0000:03:00.1` | `00:1b:21:72:dc:d1` | `lan0` | Verified by carrier and DHCP |
| `0000:04:00.0` | `00:1b:21:72:dc:d4` | `wan-backup` | Verified by DHCP and Internet access |

The backup provider device is in bridge mode. After it was rebooted, the
passed-through NIC acquired an ISP lease using its native MAC
`00:1b:21:72:dc:d4`; no MAC cloning is required.

The PPPoE cable has verified `wan-pppoe`, and the client cable has verified
`lan0`. The provider device is in bridge mode, and the PPPoE session
authenticates successfully.

## VM management

The guest has a private QEMU user-network interface. SSH is forwarded only to
the host's loopback address at port `2222`. Connect through `abiss-watcher`:

```bash
ssh \
  -o HostKeyAlias=router-vm \
  -o 'ProxyCommand=ssh ruan@192.168.0.10 -W 127.0.0.1:2222' \
  ruan@127.0.0.1
```

The expected ED25519 host-key fingerprint is:

```text
SHA256:T3RuyhsHMidZQRstGMEPTFfAwMdkjzEtrJBHtNAVP1w
```

Useful host-side commands:

```bash
systemctl status microvm@router
machinectl status router
journalctl -u microvm@router --no-pager -n 100
sudo systemctl restart microvm@router
```

AdGuard Home administration will be available at
`http://192.168.0.1:3000` after LAN cutover. Create its administrator
credentials before treating the LAN as trusted.

## PPPoE

PPPoE credentials are encrypted in `secrets/router.yaml`. sops-nix renders a
root-only pppd options file at runtime with content equivalent to:

```text
user "provider-user"
password "provider-password"
```

FireHOL's `link-balancer` owns the IPv4 default route; the FireHOL firewall is
not enabled, and nftables remains the sole firewall and NAT owner. PPPoE is the
primary gateway and DHCP WAN is declared as its fallback. Dedicated host routes
pin `1.1.1.1` and `8.8.8.8` probes to PPPoE, and `9.9.9.9` and
`208.67.222.222` probes to the backup WAN.

A gateway is demoted after three failed health cycles and restored after two
successful cycles. The validated upstream-failure test kept `ppp0` connected,
blocked only its probe destinations, moved LAN Internet and DNS to the backup,
and restored PPPoE after the probes recovered. Do not test failover with
`ip link set ... down`; administratively changing a networkd-managed interface
is disruptive and is not representative of an upstream-only failure. Existing
connections do not survive provider changes because the public source address
changes.

The router age recipient is:

```text
age1fcp425qrw9c8ca6zqt8q38yn7chkvucfa0kz0g3je93a79t2yywqehx5u2
```

## Remaining work

1. Measure each link before adding CAKE upload and IFB download rates.
2. Add weighted routing and IPv6 only after IPv4 failover is stable.

To stop the guest without affecting the host's onboard management link:

```bash
sudo systemctl stop microvm@router
```

The Intel ports remain assigned to `vfio-pci` until the VM restarts or the host
reboots. The onboard `enp8s0` interface is not in the passthrough group and
continues to provide `abiss-watcher` access independently.
