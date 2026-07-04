# ST-PUSAT CLEAN

**Pure shell autoscript VPN — no binary obfuscation, fully auditable.**

## Features

| Service | Details |
|---------|---------|
| OpenSSH | Port 22, 2222, 2223 |
| Dropbear | Port 109, 143 |
| Nginx | Port 443 (SSL termination + WS/gRPC proxy) |
| Xray-core | Latest version — VMess, VLESS, Trojan, Shadowsocks via WS & gRPC |
| OpenVPN | UDP 1194 |
| SlowDNS | DNSTT tunnel via port 5300 |
| UDP Custom | BadVPN UDPGW on ports 7100, 7200, 7300 |
| Telegram Bot | Multi-login & quota notifications |
| User Management | CRUD via menu or CLI |
| Limit IP | Auto-kick multi-login users |
| Quota | Traffic monitoring via Xray API |
| Backup | Rclone + Telegram notification |

## Installation

```bash
apt update && apt upgrade -y
wget -q https://raw.githubusercontent.com/Arya-Blitar22/st-pusat/main/setup.sh
chmod +x setup.sh && ./setup.sh
```

## System Requirements

- Debian 10, 11, 12, 13
- Ubuntu 20.04, 22.04, 24.04
- x86_64 or aarch64
- Root access

## Quick Start

After installation, type `menu` to access the management interface.

```
  SSH Management → Add/Delete/Check SSH Users
  VMess/VLESS/Trojan/SS → Add/Delete/Check/Extend
  System Settings → Certificate, Restart, Bandwidth
  Backup & Restore → Manual or automated backup
```

## Directory Layout

```
/usr/local/sbin/     → User management scripts
  menu               → Main menu
  add-vmess           → Add VMess user
  del-vmess           → Delete VMess user
  ...                 → Same for vless, trojan, ssh, ss
  limit-ip            → Multi-login detection
  quota               → Bandwidth monitoring
  xp                  → Expiry checker
  backup              → Backup all data

/etc/st-pusat/        → Library files
  lib/colors.sh       → Color definitions
  lib/utils.sh        → Utility functions
  lib/telegram.sh     → Telegram notification

/etc/xray/            → Xray configuration
  config.json         → Main config
  xray.crt / xray.key → SSL certificates
```

## File Structure (43 files, ~192KB)

```
st-pusat/
├── setup.sh           → Entry point installer
├── lib/               → Color, utils, telegram
├── install/           → Modular installation scripts
├── config/            → Templates: nginx, xray, ssh, more
├── services/          → Systemd unit files
├── scripts/           → User CRUD, monitoring, system
└── menu/              → Interactive menu
```

## Security

- All scripts are **pure bash** — no compiled/obfuscated binaries
- No hardcoded credentials (expects user input for Telegram, Cloudflare)
- Xray core via official installer (latest version)
- SSL via Let's Encrypt (auto-renewal)
- Fail2ban for brute-force protection
- Torrent blocked via iptables string matching
