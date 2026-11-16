"""Publish local routing state without exposing credentials or management actions."""

import datetime
import html
import json
import os
from pathlib import Path
import subprocess
import time


def ip_json(*args):
    result = subprocess.run(
        ["ip", "-j", "-4", *args], capture_output=True, text=True, timeout=5,
        check=True,
    )
    return json.loads(result.stdout)


def collect():
    addresses = {
        interface["ifname"]: ", ".join(
            address["local"] for address in interface.get("addr_info", [])
            if address.get("scope") == "global"
        )
        for interface in ip_json("address", "show")
    }
    defaults = ip_json("route", "show", "default")
    active = min(defaults, key=lambda route: route.get("metric", 0)).get("dev") if defaults else None
    links = {}
    for name, interface, health_name in [
        ("pppoe", os.environ["PPP_INTERFACE"], "primary"),
        ("dhcp", os.environ["DHCP_INTERFACE"], "backup"),
    ]:
        address = addresses.get(interface, "")
        try:
            health_file = Path(f"/run/link-balancer/health-{health_name}")
            health = health_file.read_text().split()[0]
            if time.time() - health_file.stat().st_mtime > 120:
                health = "unknown"
        except (OSError, IndexError):
            health = "unknown"
        status = "Disconnected" if not address else {
            "up": "Healthy", "down": "Unhealthy",
        }.get(health, "Connected (health unknown)")
        links[name] = {"status": status, "address": address or "None", "active": interface == active}
    return {
        "updated": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "active": next((name.upper() for name, link in links.items() if link["active"]), "None"),
        **links,
    }


def publish(directory=Path("/run/router-status")):
    status = collect()
    rows = "".join(
        "<tr>" + "".join(f"<td>{html.escape(str(value))}</td>" for value in (
            name.upper(), status[name]["status"], status[name]["address"],
            "Yes" if status[name]["active"] else "No",
        )) + "</tr>"
        for name in ("pppoe", "dhcp")
    )
    page = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<meta http-equiv="refresh" content="10"><title>Router status</title>
<style>body{{font:18px system-ui;max-width:900px;margin:3rem auto;padding:1rem;background:#18202b;color:#eee}}
a{{color:#8dcaff}}table{{width:100%;border-collapse:collapse}}th,td{{text-align:left;padding:1rem;border-bottom:1px solid #567}}</style>
</head><body><h1>Router status</h1><p>Active internet link: <strong>{status['active']}</strong></p>
<table><thead><tr><th>Link</th><th>Health</th><th>WAN address</th><th>Active route</th></tr></thead>
<tbody>{rows}</tbody></table><p>Health is reported by the router's failover monitor, not just cable carrier.</p>
<p>Updated: {html.escape(status['updated'])} (refreshes every 10 seconds).</p>
<p><a href="http://192.168.0.1:3000">AdGuard Home</a> · <a href="http://192.168.0.10:8082">Homepage</a></p>
</body></html>"""
    for name, contents in [("status.json", json.dumps(status)), ("index.html", page)]:
        temporary = directory / f".{name}.tmp"
        temporary.write_text(contents)
        temporary.replace(directory / name)


if __name__ == "__main__":
    publish()
