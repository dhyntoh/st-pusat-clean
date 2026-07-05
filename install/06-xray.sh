#!/bin/bash
# Xray configuration
setup_xray() {
    section "XRAY CORE"

    # Copy config to Xray's actual config path
    mkdir -p /usr/local/etc/xray
    cp "$BASE_DIR/config/xray/config.json" /usr/local/etc/xray/config.json
    cp "$BASE_DIR/config/xray/config.json" /etc/xray/config.json

    # Create symlink so both paths stay in sync
    ln -sf /usr/local/etc/xray/config.json /etc/xray/config.json 2>/dev/null || true

    # Create xray service if not exists
    if [[ ! -f /etc/systemd/system/xray.service ]]; then
        cat > /etc/systemd/system/xray.service <<'EOF'
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
    fi

    # Run service setup
    mkdir -p /run/xray
    chown www-data:www-data /run/xray

    systemctl daemon-reload
    systemctl enable xray 2>/dev/null
    systemctl restart xray

    # Verify
    sleep 2
    if systemctl is-active xray &>/dev/null; then
        ok "Xray active: $(xray version 2>/dev/null | head -1)"
    else
        error "Xray failed to start. Check: systemctl status xray"
    fi
}
