#!/bin/bash
# Cron jobs setup
setup_cron() {
    section "CRON JOBS"

    # Expiry checker (daily at 00:02)
    cat > /etc/cron.d/xp_all <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/xp
EOF

    # Log cleaner (every 20 min)
    cat > /etc/cron.d/logclean <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/20 * * * * root /usr/local/sbin/clearlog
EOF

    # Daily reboot (5 AM)
    cat > /etc/cron.d/daily_reboot <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * root /sbin/reboot
EOF

    # Backup (1 AM)
    cat > /etc/cron.d/backup <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 1 * * * root /usr/local/sbin/backup
EOF

    # Limit IP check (every 2 min)
    cat > /etc/cron.d/limit_ip <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/2 * * * * root /usr/local/sbin/limit-ip
EOF

    # Clear nginx & xray logs (every min)
    echo "*/1 * * * * root echo -n > /var/log/nginx/access.log" > /etc/cron.d/log.nginx
    echo "*/1 * * * * root echo -n > /var/log/xray/access.log" >> /etc/cron.d/log.xray

    # Profile
    cat > /root/.profile <<'EOF'
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
menu
EOF

    # Shells
    echo "/bin/false" >> /etc/shells 2>/dev/null
    echo "/usr/sbin/nologin" >> /etc/shells 2>/dev/null

    # rc.local
    cat > /etc/rc.local <<'EOF'
#!/bin/sh -e
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
systemctl restart netfilter-persistent
exit 0
EOF
    chmod +x /etc/rc.local
    systemctl enable rc-local 2>/dev/null

    systemctl restart cron
    ok "Cron jobs configured (expiry, reboot, backup, limit)"
}
