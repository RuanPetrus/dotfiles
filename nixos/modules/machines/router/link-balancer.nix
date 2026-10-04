{
  config,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.router;
  pppInterface = "ppp0";
  primaryChecks = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  backupChecks = [
    "9.9.9.9"
    "208.67.222.222"
  ];
  linkBalancer = "${pkgs.firehol}/bin/link-balancer";

  linkBalancerLoop = pkgs.writeShellApplication {
    name = "link-balancer-loop";
    runtimeInputs = with pkgs; [
      coreutils
      firehol
      gawk
      iproute2
      util-linux
    ];
    text = ''
      primary_interface=${pppInterface}
      backup_interface=${cfg.dhcpWanInterface}

      while true; do
        primary_source="$(ip -4 -o address show dev "$primary_interface" scope global 2>/dev/null | awk 'NR == 1 { sub(/\/.*/, "", $4); print $4 }')"
        if [[ -n "$primary_source" ]]; then
          for target in ${builtins.concatStringsSep " " primaryChecks}; do
            ip -4 route replace "$target/32" dev "$primary_interface" src "$primary_source"
          done
        else
          for target in ${builtins.concatStringsSep " " primaryChecks}; do
            ip -4 route del "$target/32" 2>/dev/null || true
          done
        fi

        backup_source="$(ip -4 -o address show dev "$backup_interface" scope global 2>/dev/null | awk 'NR == 1 { sub(/\/.*/, "", $4); print $4 }')"
        backup_gateway=""
        ifindex_file="/sys/class/net/$backup_interface/ifindex"
        if [[ -r "$ifindex_file" ]]; then
          lease_file="/run/systemd/netif/leases/$(< "$ifindex_file")"
          if [[ -r "$lease_file" ]]; then
            while IFS='=' read -r key value; do
              if [[ "$key" == "ROUTER" ]]; then
                backup_gateway="$value"
                break
              fi
            done < "$lease_file"
          fi
        fi

        if [[ -n "$backup_source" && -n "$backup_gateway" ]]; then
          for target in ${builtins.concatStringsSep " " backupChecks}; do
            ip -4 route replace "$target/32" via "$backup_gateway" dev "$backup_interface" src "$backup_source"
          done
        else
          for target in ${builtins.concatStringsSep " " backupChecks}; do
            ip -4 route del "$target/32" 2>/dev/null || true
          done
        fi

        if ! ${linkBalancer} >/dev/null 2>&1; then
          logger -t link-balancer "route reconciliation failed"
        fi
        sleep 10
      done
    '';
  };
in
{
  environment = {
    etc."firehol/link-balancer.conf".text = ''
      LB_DEFAULT_IPV=4

      check_hysteresis() {
          local dev="$1"
          local src="$2"
          local name="$3"
          local state_file="/run/link-balancer/health-$name"
          local health="up"
          local failures=0
          local successes=0
          local targets=""

          case "$name" in
              primary) targets="${builtins.concatStringsSep " " primaryChecks}" ;;
              backup) targets="${builtins.concatStringsSep " " backupChecks}" ;;
              *) return 1 ;;
          esac

          if [[ -r "$state_file" ]]; then
              read -r health failures successes < "$state_file"
          fi

          local reachable=1
          local target
          for target in $targets; do
              if "$PING_CMD" -I "$src" -c 1 -W 2 "$target" >/dev/null 2>&1; then
                  reachable=0
                  break
              fi
          done

          if [[ "$reachable" -eq 0 ]]; then
              failures=0
              if [[ "$health" == "down" ]]; then
                  successes=$((successes + 1))
                  if [[ "$successes" -ge 2 ]]; then
                      health="up"
                      successes=0
                      ${pkgs.util-linux}/bin/logger -t link-balancer-health "$name recovered on $dev"
                  fi
              else
                  successes=0
              fi
          else
              successes=0
              if [[ "$health" == "up" ]]; then
                  failures=$((failures + 1))
                  if [[ "$failures" -ge 3 ]]; then
                      health="down"
                      failures=0
                      ${pkgs.util-linux}/bin/logger -t link-balancer-health "$name failed on $dev"
                  fi
              else
                  failures=0
              fi
          fi

          printf '%s %s %s\n' "$health" "$failures" "$successes" > "$state_file.tmp"
          ${pkgs.coreutils}/bin/mv "$state_file.tmp" "$state_file"
          [[ "$health" == "up" ]]
      }

      backup_gateway=""
      ifindex_file="/sys/class/net/${cfg.dhcpWanInterface}/ifindex"
      if [[ -r "$ifindex_file" ]]; then
          lease_file="/run/systemd/netif/leases/$(< "$ifindex_file")"
          if [[ -r "$lease_file" ]]; then
              while IFS='=' read -r key value; do
                  if [[ "$key" == "ROUTER" ]]; then
                      backup_gateway="$value"
                      break
                  fi
              done < "$lease_file"
          fi
      fi

      primary_gateway="$(${pkgs.iproute2}/bin/ip -4 route show dev ${pppInterface} proto kernel scope link 2>/dev/null | ${pkgs.gawk}/bin/awk 'NR == 1 { print $1 }')"
      if [[ -n "$primary_gateway" ]]; then
          gateway primary dev ${pppInterface} gw "$primary_gateway" check hysteresis primary
      fi
      if [[ -n "$backup_gateway" ]]; then
          gateway backup dev ${cfg.dhcpWanInterface} gw "$backup_gateway" check hysteresis backup
      fi

      table main
          if [[ -n "$primary_gateway" ]]; then
              default via primary
          fi
          if [[ -n "$backup_gateway" ]]; then
              fallback via backup
          fi
    '';

    systemPackages = [ pkgs.firehol ];
  };

  systemd.services.link-balancer = {
    description = "FireHOL multi-WAN link balancer";
    after = [
      "pppd-primary.service"
      "systemd-networkd.service"
    ];
    wants = [
      "pppd-primary.service"
      "systemd-networkd.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${linkBalancerLoop}/bin/link-balancer-loop";
      Restart = "always";
      RestartSec = "2s";
    };
  };
}
