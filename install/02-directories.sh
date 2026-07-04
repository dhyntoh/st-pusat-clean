#!/bin/bash
# Create directory structure
create_dirs() {
    section "CREATING DIRECTORIES"

    mkdir -p /etc/xray
    mkdir -p /var/log/xray
    mkdir -p /var/www/html
    mkdir -p /etc/vmess
    mkdir -p /etc/vless
    mkdir -p /etc/trojan
    mkdir -p /etc/shadowsocks
    mkdir -p /etc/ssh
    mkdir -p /etc/bot
    mkdir -p /etc/user-create
    mkdir -p /etc/kyt/limit/vmess/ip
    mkdir -p /etc/kyt/limit/vless/ip
    mkdir -p /etc/kyt/limit/trojan/ip
    mkdir -p /etc/kyt/limit/ssh/ip
    mkdir -p /etc/limit/vmess
    mkdir -p /etc/limit/vless
    mkdir -p /etc/limit/trojan
    mkdir -p /etc/limit/ssh
    mkdir -p /etc/slowdns
    mkdir -p /usr/local/kyt
    mkdir -p /run/xray

    chown www-data:www-data /var/log/xray
    chown www-data:www-data /run/xray 2>/dev/null
    chmod +x /var/log/xray

    # Create database files
    for db in /etc/vmess/.vmess.db /etc/vless/.vless.db /etc/trojan/.trojan.db /etc/shadowsocks/.shadowsocks.db /etc/ssh/.ssh.db /etc/bot/.bot.db; do
        touch "$db"
    done

    echo "& plug-in Account" >> /etc/vmess/.vmess.db
    echo "& plug-in Account" >> /etc/vless/.vless.db
    echo "& plug-in Account" >> /etc/trojan/.trojan.db
    echo "& plug-in Account" >> /etc/shadowsocks/.shadowsocks.db
    echo "& plug-in Account" >> /etc/ssh/.ssh.db

    ok "Directories created"
}
