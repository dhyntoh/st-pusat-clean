# ST-PUSAT CLEAN

**Pure shell autoscript VPN** — tanpa binary/ELF obfuscation, 100% bisa diaudit.

Fork dari [Arya-Blitar22/st-pusat](https://github.com/Arya-Blitar22/st-pusat) yang di-rebuild total:
- ❌ Semua file `.sh` (setup, menu, dll) adalah **ELF binary** → ✅ **Shell script murni**
- ❌ Xray `--version 1.8.23` dipaksa → ✅ **Latest Xray-core** via official installer
- ❌ Port number string (`"10001"`) → ✅ **Number** sesuai spek JSON
- ❌ HAProxy config hanya komentar → ❌ **Dihapus**, Nginx langsung handle port 443
- ❌ Hardcoded credentials (Telegram token, Cloudflare API key) → ✅ **Input user**
- ❌ Password gate `CANTIKA20` → ✅ **Bebas akses**
- ❌ Binary `udp-mini` target kernel 2.6.18 → ✅ **badvpn-udpgw** dari apt (stable)
- ❌ Routing Xray duplikat → ✅ **Dibersihkan**, sniffing enabled
- ❌ GCC 9.4 (Ubuntu 20.04) — inkompatibel Debian 13 → ✅ **Kompatibel** Debian 10-13 & Ubuntu 20-25

---

## Fitur Lengkap

### Protokol
| Layanan | Detail |
|---------|--------|
| **OpenSSH** | Port 22, 2222, 2223 |
| **Dropbear** | Port 109, 143 |
| **Nginx** | Port 443 — SSL termination + reverse proxy WS & gRPC |
| **Xray-core** | ✅ VMess (WS/gRPC), ✅ VLESS (WS/gRPC), ✅ Trojan (WS/gRPC), ✅ Shadowsocks (WS/gRPC) |
| **SlowDNS** | DNSTT tunnel via port 5300 (Cloudflare NS) |
| **UDP Custom** | BadVPN UDPGW — port 7100, 7200, 7300 |
| **OpenVPN** | UDP port 1194 (opsional saat instalasi) |

### Management
| Fitur | Keterangan |
|-------|------------|
| **Menu** | 🖥️ TUI — ketik `menu` setelah login |
| **User CRUD** | add/del/cek/renew untuk SSH, VMess, VLESS, Trojan, Shadowsocks |
| **Generate Link** | Setiap nambah user langsung dapat link koneksi (VMess://, VLESS://, trojan://) |
| **Limit IP** | 🔒 Multi-login detection — auto-kick + notif Telegram |
| **Quota** | 📊 Traffic monitoring via Xray API stats |
| **Expiry** | ⏰ Cron daily — auto-hapus user expired + notif |
| **Backup** | 💾 Backup config & database + notif Telegram |
| **Telegram Bot** | 🤖 Notifikasi instalasi, multi-login, quota habis, user expired |

### Keamanan
- ✅ SSL Let's Encrypt (auto-renew via acme.sh)
- ✅ Fail2ban terinstall (brute-force protection)
- ✅ Torrent diblokir via iptables string matching
- ✅ Network tuning (BBR, fs.file-max, TCP buffers)
- ✅ iptables-persistent — rules survive reboot

---

## Instalasi

### Debian / Ubuntu

```bash
apt update && apt upgrade -y
wget -q https://raw.githubusercontent.com/dhyntoh/st-pusat-clean/master/setup.sh
chmod +x setup.sh && ./setup.sh
```

### System Requirements

- **OS**: Debian 10, 11, 12, 13 / Ubuntu 20.04, 22.04, 24.04
- **Arch**: x86_64 atau aarch64
- **RAM**: Minimal 512MB (recommended 1GB+)
- **Disk**: Minimal 2GB free
- **Root access**: Wajib

---

## Cara Penggunaan

Setelah instalasi selesai dan login ulang, ketik `menu`:

```
  ┌─────────────────────────────────────────┐
  │           ST-PUSAT CLEAN MENU           │
  ├─────────────────────────────────────────┤
  │  1) SSH Management                       │
  │  2) VMess Management                     │
  │  3) VLESS Management                     │
  │  4) Trojan Management                    │
  │  5) Shadowsocks Management               │
  │  6) System Settings                      │
  │  7) Backup & Restore                     │
  │    ...                                   │
  └─────────────────────────────────────────┘
```

### Contoh: Tambah user VMess
1. Pilih menu `2) VMess Management`
2. Pilih `1) Add VMess User`
3. Masukkan username, quota, limit IP, masa berlaku
4. Dapat link koneksi langsung

```
━━━━ VMESS USER CREATED ━━━━
Username : user1
UUID     : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Domain   : vpn.domainkamu.com
Port     : 443
Path     : /vmess
TLS      : Yes
Expiry   : 2026-08-04
Link     : vmess://...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Struktur File

```
/root/st-pusat-clean/
├── setup.sh           → Entry point installer (55 file total, 240KB)
├── lib/               → colors.sh, utils.sh, telegram.sh
├── install/           → 00-precheck sampai 12-finalize (modular)
│   ├── 00-precheck.sh → Cek OS, root, arch, virtualisasi
│   ├── 01-packages.sh → Install apt packages + Xray + badvpn
│   ├── 02-directories.sh → Struktur folder & database
│   ├── 03-domain.sh   → Input domain + SSL Let's Encrypt
│   ├── 04-ssh.sh      → OpenSSH (22,2222,2223) + Dropbear (109,143)
│   ├── 05-nginx.sh    → SSL termination + WS/grpc reverse proxy
│   ├── 06-xray.sh     → Config multi-protocol (10001-10008)
│   ├── 07-other.sh    → OpenVPN, SlowDNS, UDP, iptables
│   ├── 08-cron.sh     → Cron jobs + rc.local
│   ├── 10-telegram.sh → Bot notifikasi
│   └── 12-finalize.sh → Deploy script + enable service + reboot
├── config/            → Template config (xray, nginx, ssh, dll)
├── services/          → Systemd unit files
├── scripts/           → User CRUD, limit-ip, quota, xp, backup
│   ├── user/          → add/del/cek/renew per protokol
│   ├── monitor/       → limit-ip.sh (multi-login), quota.sh (traffic)
│   └── system/        → xp.sh, backup.sh, fixcert.sh, clearlog.sh
└── menu/              → Interactive bash TUI
```

### Setelah instalasi, script di-deploy ke:

```
/usr/local/sbin/
├── menu            → Main menu (TUI)
├── add-ssh         → Tambah user SSH
├── del-ssh         → Hapus user SSH
├── cek-ssh         → List user SSH
├── add-vmess       → Tambah user VMess + generate link
├── del-vmess       → Hapus user VMess
├── cek-vmess       → List user VMess
├── renew-vmess     → Perpanjang masa berlaku
├── add-vless       → Tambah user VLESS + generate link
├── add-trojan      → Tambah user Trojan + generate link
├── add-ss          → Tambah user Shadowsocks
├── limit-ip        → Deteksi & kick multi-login (cron tiap 2 menit)
├── quota           → Monitor traffic via Xray API (cron tiap 2 menit)
├── xp              → Hapus user expired (cron tiap hari jam 00:02)
├── backup          → Backup config + database
├── fixcert         → Renew SSL certificate
├── clearlog        → Bersihin log (cron tiap 20 menit)
├── restart         → Restart semua service
├── bw              → Cek bandwidth via vnstat
└── cek-all         → Lihat semua user sekaligus
```

---

## Perbandingan dengan st-pusat asli

| Aspek | Asli (Arya-Blitar22) | Clean (dhyntoh) |
|-------|----------------------|------------------|
| **Format** | ELF binary (tidak bisa diaudit) | ✅ Shell script murni |
| **Xray** | `--version 1.8.23` (dipaksa) | ✅ Latest via official installer |
| **HAProxy** | Config kosong, gak fungsi | ❌ Dihapus — Nginx handle langsung |
| **SSL** | Standalone (ganggu service lain) | ✅ acme.sh + reloadcmd |
| **UDP** | Binary kernel 2.6.18 | ✅ badvpn-udpgw (apt) |
| **Password** | `CANTIKA20` (hardcoded) | ✅ Tanpa gate |
| **Credentials** | Hardcoded di script | ✅ Input user |
| **Port format** | String (`"10001"`) | ✅ Number (`10001`) |
| **Debian 13** | ❌ Segfault (glibc lama) | ✅ Full kompatibel |
| **Routing** | Duplikat, berantakan | ✅ Bersih, sniffing enabled |

---

## Kredit

- **Arya-Blitar22** — Original st-pusat concept & fitur
- **Repo ini** — Rebuild total sebagai shell script murni, tanpa binary

## Lisensi

MIT — bebas pakai, bebas modifikasi.
