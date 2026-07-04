#!/bin/bash
# Finalize installation
finalize() {
    section "DEPLOYING SCRIPTS"

    # Deploy menu system
    mkdir -p /etc/st-pusat/menu
    cp "$BASE_DIR/menu/menu.sh" /etc/st-pusat/menu/
    ln -sf /etc/st-pusat/menu/menu.sh /usr/local/sbin/menu 2>/dev/null

    # Deploy user management scripts
    for script in add-ssh del-ssh cek-ssh \
                  add-vmess del-vmess cek-vmess renew-vmess \
                  add-vless del-vless renew-vless \
                  add-trojan del-trojan renew-trojan \
                  add-ss del-ss; do
        if [[ -f "$BASE_DIR/scripts/user/${script}.sh" ]]; then
            cp "$BASE_DIR/scripts/user/${script}.sh" "/usr/local/sbin/${script}"
            chmod +x "/usr/local/sbin/${script}"
        fi
    done

    # Deploy system scripts
    for script in xp clearlog fixcert restart bw cek-all backup update; do
        if [[ -f "$BASE_DIR/scripts/system/${script}.sh" ]]; then
            cp "$BASE_DIR/scripts/system/${script}.sh" "/usr/local/sbin/${script}"
            chmod +x "/usr/local/sbin/${script}"
        fi
    done

    # Also deploy monitor scripts if they exist
    for script in limit-ip quota; do
        if [[ -f "$BASE_DIR/scripts/monitor/${script}.sh" ]]; then
            cp "$BASE_DIR/scripts/monitor/${script}.sh" "/usr/local/sbin/${script}"
            chmod +x "/usr/local/sbin/${script}"
        fi
    done

    ok "All scripts deployed to /usr/local/sbin/"

    section "FINALIZING SERVICES"

    systemctl daemon-reload

    # Enable & restart all services
    for svc in nginx xray dropbear cron rc-local netfilter-persistent; do
        systemctl enable $svc 2>/dev/null
        systemctl restart $svc 2>/dev/null || true
    done

    # UDPGW services
    for port in 7100 7200 7300; do
        systemctl enable "udpgw-${port}" 2>/dev/null || true
        systemctl start "udpgw-${port}" 2>/dev/null || true
    done

    # SlowDNS
    systemctl enable slowdns-server 2>/dev/null || true

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

    # Cleanup
    rm -rf /root/*.zip /root/LICENSE /root/README.md /root/domain 2>/dev/null
    history -c
    echo "unset HISTFILE" >> /etc/profile

    # Save install log
    local DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "none")
    local IP=$(get_ip)
    cat > /root/log-install.txt <<INSTALOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ST-PUSAT CLEAN - INSTALLATION LOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tanggal    : $(date)
OS         : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
IP         : $IP
Domain     : $DOMAIN

Services:
- OpenSSH  : 22, 2222, 2223
- Dropbear : 109, 143
- Nginx    : 443 (SSL)
- Xray     : 10001-10008 (internal)
- OpenVPN  : 1194
- SlowDNS  : 5300
- UDPGW    : 7100, 7200, 7300

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

    # Send TG notification
    source /etc/st-pusat/lib/telegram.sh 2>/dev/null || true
    tg_send "<b>INSTALASI BERHASIL</b>%0A<b>IP:</b> $IP%0A<b>Domain:</b> $DOMAIN" 2>/dev/null || true

    if confirm "Reboot now?"; then
        reboot
    fi
}
