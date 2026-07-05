#!/bin/bash
# Domain & SSL setup
setup_domain() {
    section "DOMAIN SETUP"
    echo ""
    echo "  1) Use own domain (recommended)"
    echo "  2) Use random domain"
    read -p "$(echo -e ${YELLOW}"➤${NC} Select [1-2]: ")" host_choice
    if [[ "$host_choice" == "1" ]]; then
        prompt "Enter your domain (e.g., vpn.yourdomain.com):" DOMAIN
        echo "$DOMAIN" > /etc/xray/domain
        echo "$DOMAIN" > /root/domain
    else
        DOMAIN=$(get_ip)
        echo "$DOMAIN" > /etc/xray/domain
    fi
    ok "Domain: $(cat /etc/xray/domain)"
}

setup_ssl() {
    section "SSL CERTIFICATE"
    local domain=$(cat /etc/xray/domain 2>/dev/null || echo "")

    # If empty or IP, use self-signed
    if [[ -z "$domain" || $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        warn "Using IP address, SSL will use self-signed"
        mkdir -p /etc/xray
        openssl req -x509 -nodes -days 365 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
            -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -subj "/CN=$domain" 2>/dev/null
        ok "Self-signed certificate created"
        return
    fi

    # Check if existing valid cert from acme.sh
    local acme_home="/root/.acme.sh"
    local cert_dir="$acme_home/${domain}_ecc"
    if [[ -f "$cert_dir/fullchain.cer" ]] && [[ -f "$cert_dir/$domain.key" ]]; then
        ok "Existing certificate found for $domain"
        cp "$cert_dir/fullchain.cer" /etc/xray/xray.crt
        cp "$cert_dir/$domain.key" /etc/xray/xray.key
        chmod 644 /etc/xray/xray.crt
        chmod 600 /etc/xray/xray.key
        # Reinstall reload cmd
        "$acme_home/acme.sh" --install-cert -d "$domain" \
            --key-file /etc/xray/xray.key \
            --fullchain-file /etc/xray/xray.crt \
            --reloadcmd "systemctl restart nginx" >/dev/null 2>&1 || true
        ok "Certificate copied from existing acme.sh"
        return
    fi

    # Install acme.sh if not present
    if [[ ! -f "$acme_home/acme.sh" ]]; then
        info "Installing acme.sh..."
        curl -s https://get.acme.sh | bash -s email=admin@"$domain" >/dev/null 2>&1
    fi

    # Issue new cert
    info "Getting SSL certificate for $domain..."
    systemctl stop nginx 2>/dev/null
    fuser -k 80/tcp 2>/dev/null || true
    "$acme_home/acme.sh" --issue -d "$domain" --standalone -k ec-256 --server letsencrypt 2>&1

    if [[ $? -eq 0 ]]; then
        "$acme_home/acme.sh" --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt \
            --keypath /etc/xray/xray.key --ecc
        chmod 644 /etc/xray/xray.crt
        chmod 600 /etc/xray/xray.key
        ok "SSL certificate installed from Let's Encrypt"
        "$acme_home/acme.sh" --install-cert -d "$domain" \
            --key-file /etc/xray/xray.key \
            --fullchain-file /etc/xray/xray.crt \
            --reloadcmd "systemctl restart nginx" >/dev/null 2>&1
        ok "Auto-renewal configured"
    else
        warn "SSL from Let's Encrypt failed, using self-signed fallback"
        openssl req -x509 -nodes -days 365 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
            -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -subj "/CN=$domain" 2>/dev/null
    fi
}
