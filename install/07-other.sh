#!/bin/bash
# Other protocols: OpenVPN, SlowDNS, UDP, Wondershaper, iptables
setup_other() {
    section "ADDITIONAL PROTOCOLS"

    # Sysctl tuning
    cp "$BASE_DIR/config/other/sysctl.conf" /etc/sysctl.d/99-stpusat.conf 2>/dev/null
    sysctl -p /etc/sysctl.d/99-stpusat.conf >/dev/null 2>&1
    ok "Kernel parameters tuned (BBR, etc.)"

    # iptables rules - block torrent
    for rule in "get_peers" "announce_peer" "find_node" "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce.php?passkey=" "torrent" "announce" "info_hash"; do
        iptables -A FORWARD -m string --string "$rule" --algo bm -j DROP 2>/dev/null
    done
    netfilter-persistent save >/dev/null 2>&1
    ok "Torrent blocked via iptables"

    # OpenVPN
    if confirm "Install OpenVPN?"; then
        info "Installing OpenVPN..."
        apt install -y openvpn easy-rsa 2>&1 | tail -2

        # Generate basic certs
        mkdir -p /etc/openvpn/server
        cd /etc/openvpn/server
        if [[ ! -f ca.crt ]]; then
            openssl req -x509 -nodes -days 3650 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
                -keyout ca.key -out ca.crt -subj "/CN=ST-PUSAT-CA" 2>/dev/null
            openssl req -nodes -days 3650 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
                -keyout server.key -out server.csr -subj "/CN=server" 2>/dev/null
            openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt 2>/dev/null
        fi

        # Generate basic server config
        cat > /etc/openvpn/server.conf <<'EOF'
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh none
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
verb 3
EOF
        systemctl enable openvpn@server 2>/dev/null
        systemctl restart openvpn@server 2>/dev/null
        ok "OpenVPN configured on UDP 1194"
    fi

    # SlowDNS
    if confirm "Install SlowDNS (DNS tunnel)?"; then
        info "Setting up SlowDNS..."
        # Check if dnstt binaries exist from repo clone
        if [[ -f /tmp/st-pusat/slowdns/dnstt-server ]]; then
            cp /tmp/st-pusat/slowdns/dnstt-server /usr/local/bin/
            cp /tmp/st-pusat/slowdns/dnstt-client /usr/local/bin/
            chmod +x /usr/local/bin/dnstt-server /usr/local/bin/dnstt-client

            # Generate keys
            cd /etc/slowdns
            /usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub 2>/dev/null

            # Create service
            cat > /etc/systemd/system/slowdns-server.service <<'EOF'
[Unit]
Description=SlowDNS Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/dnstt-server -udp :5300 -privkey-file /etc/slowdns/server.key __DOMAIN__ 127.0.0.1:443
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
            sed -i "s/__DOMAIN__/$(cat /etc/xray/domain)/g" /etc/systemd/system/slowdns-server.service

            # iptables redirect DNS
            iptables -I INPUT -p udp --dport 5300 -j ACCEPT 2>/dev/null
            iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null
            netfilter-persistent save >/dev/null 2>&1

            systemctl daemon-reload
            systemctl enable slowdns-server 2>/dev/null
            systemctl start slowdns-server 2>/dev/null
            ok "SlowDNS configured on port 5300"
        else
            warn "dnstt binaries not found, skipping SlowDNS"
        fi
    fi

    # UDP Custom (badvpn)
    if confirm "Install UDP Custom (badvpn)?"; then
        info "Setting up badvpn-udpgw..."
        BADVPN=$(which badvpn-udpgw 2>/dev/null || echo /usr/local/bin/badvpn-udpgw)

        for port in 7100 7200 7300; do
            cat > /etc/systemd/system/udpgw-${port}.service <<UNIT
[Unit]
Description=BadVPN UDPGW $port
After=network.target

[Service]
Type=simple
User=root
ExecStart=$BADVPN --listen-addr 127.0.0.1:$port --max-clients 500
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
            systemctl enable udpgw-${port} 2>/dev/null
            systemctl start udpgw-${port} 2>/dev/null
        done
        ok "UDPGW running on ports 7100, 7200, 7300"
    fi
}
