#!/bin/bash
# Finalize installation - deploy scripts and services
finalize() {
    section "DEPLOYING MENU & SCRIPTS"

    # Deploy the original menu binaries (extracted from the ELF packer)
    mkdir -p /tmp/menu-install
    cd /tmp/menu-install
    unzip -o "$BASE_DIR/menu/original-binaries.zip" 2>/dev/null
    cp -a menu/* /usr/local/sbin/ 2>/dev/null
    chmod +x /usr/local/sbin/* 2>/dev/null
    rm -rf /tmp/menu-install
    ln -sf /usr/local/sbin/menu /usr/bin/menu 2>/dev/null
    ok "Original menu system deployed (90+ commands)"

    # Copy library files
    mkdir -p /etc/st-pusat/lib
    cp "$BASE_DIR/lib/colors.sh" /etc/st-pusat/lib/
    cp "$BASE_DIR/lib/utils.sh" /etc/st-pusat/lib/
    cp "$BASE_DIR/lib/telegram.sh" /etc/st-pusat/lib/ 2>/dev/null || true

    # Setup profile
    cat > /root/.profile <<'EOF'
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
menu
EOF

    section "FINALIZING SERVICES"

    systemctl daemon-reload

    # Enable & restart services
    for svc in nginx xray dropbear cron rc-local netfilter-persistent; do
        systemctl enable $svc 2>/dev/null
        systemctl restart $svc 2>/dev/null || true
    done

    # UDPGW services
    for port in 7100 7200 7300; do
        systemctl enable "udpgw-${port}" 2>/dev/null || true
        systemctl start "udpgw-${port}" 2>/dev/null || true
    done

    # Telegram notification service (auto-starts on reboot)
    cp "$BASE_DIR/services/stpusat-bot.service" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable stpusat-bot 2>/dev/null
    systemctl restart stpusat-bot 2>/dev/null || true

    # SlowDNS
    systemctl enable slowdns-server 2>/dev/null || true

    # Cleanup
    rm -rf /root/*.zip /root/LICENSE /root/README.md /root/domain 2>/dev/null
    history -c
    echo "unset HISTFILE" >> /etc/profile

    # Save install log
    local DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "none")
    local IP=$(get_ip 2>/dev/null || curl -s ipinfo.io/ip)
    cat > /root/log-install.txt <<INSTALOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ST-PUSAT CLEAN - INSTALLATION LOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tanggal    : $(date)
OS         : $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)
IP         : $IP
Domain     : $DOMAIN

Services:
- OpenSSH  : 22, 2222, 2223
- Dropbear : 109, 143
- Nginx    : 443 (SSL)
- Xray     : 10001-10008 (internal)
- UDPGW    : 7100, 7200, 7300
- Telegram Bot: Active

User management: Type 'menu' after login
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALOG

    ok "Installation complete!"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}INSTALLATION SUCCESSFUL${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  IP      : $IP"
    echo -e "  Domain  : $DOMAIN"
    echo -e "  Type ${GREEN}menu${NC} to manage users"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if confirm "Reboot now?"; then
        reboot
    fi
}
