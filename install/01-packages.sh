#!/bin/bash
# Package installation
install_packages() {
    section "INSTALLING PACKAGES"

    export DEBIAN_FRONTEND=noninteractive
    local START_TIME=$(date +%s)

    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

    apt update -y
    apt upgrade -y

    info "Installing packages one by one (skipping if not found)..."

    # List of all packages we want (each installed separately)
    PKGS_ALL="
        nginx openssl cron socat zip unzip wget curl jq vnstat
        stunnel4 ca-certificates gnupg lsb-release dnsutils bc screen git
        iptables iptables-persistent netfilter-persistent net-tools fail2ban
        build-essential cmake uuid-runtime
        python3 python3-pip
        ruby whois rclone netcat-traditional

    "

    local installed=0 skipped=0
    for pkg in $PKGS_ALL; do
        if apt install -y "$pkg" 2>/dev/null; then
            ((installed++))
        else
            ((skipped++))
        fi
    done

    # Dropbear - handle separately (package name differs by distro)
    if apt install -y dropbear 2>/dev/null || apt install -y dropbear-bin 2>/dev/null; then
        ((installed++))
    else
        warn "Dropbear not in repo, skipping"
        ((skipped++))
    fi

    ok "Packages: $installed installed, $skipped skipped"

    # lolcat via gem
    if command -v gem &>/dev/null && ! command -v lolcat &>/dev/null; then
        gem install lolcat 2>/dev/null || true
    fi

    # BadVPN
    info "Installing badvpn-udpgw..."
    if ! command -v badvpn-udpgw &>/dev/null; then
        if apt install -y badvpn-bin 2>/dev/null || apt install -y badvpn 2>/dev/null; then
            ok "badvpn from apt"
        else
            cd /tmp && git clone --depth=1 https://github.com/ambrop72/badvpn.git 2>/dev/null
            if [[ -d badvpn ]]; then
                cd badvpn && cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 >/dev/null 2>&1 && make >/dev/null 2>&1
                cp udpgw/badvpn-udpgw /usr/local/bin/ 2>/dev/null
                cd / && rm -rf /tmp/badvpn
                ok "badvpn built from source"
            fi
        fi
    fi
    command -v badvpn-udpgw &>/dev/null && ok "badvpn-udpgw ready" || warn "badvpn not available"

    # Xray
    info "Installing Xray core (latest)..."
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data 2>&1 | tail -2
    if command -v xray &>/dev/null; then
        ok "Xray: $(xray version 2>/dev/null | head -1)"
    else
        warn "Xray install may have failed"
    fi

    local END_TIME=$(date +%s)
    info "Package installation took $(secs_to_human $((END_TIME - START_TIME)))"
}
