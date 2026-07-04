#!/bin/bash
# Package installation
install_packages() {
    section "INSTALLING PACKAGES"

    export DEBIAN_FRONTEND=noninteractive
    local START_TIME=$(date +%s)

    # Pre-seed iptables-persistent
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

    apt update -y
    apt upgrade -y

    info "Installing base packages..."
    apt install -y \
        nginx \
        dropbear \
        stunnel4 \
        openssl \
        cron \
        socat \
        netcat-openbsd \
        zip unzip \
        wget curl \
        jq \
        vnstat \
        fail2ban \
        rclone \
        ruby \
        lolcat \
        python3 python3-pip \
        iptables iptables-persistent netfilter-persistent \
        net-tools \
        ca-certificates \
        gnupg \
        lsb-release \
        dnsutils \
        bc \
        screen \
        git \
        build-essential \
        cmake \
        uuid-runtime \
        wondershaper \
        whois \
        2>&1 | tail -2

    if [[ $? -eq 0 ]]; then
        ok "Base packages installed"
    else
        warn "Some packages may have failed (non-critical)"
    fi

    # Install badvpn for UDP
    info "Installing badvpn..."
    apt install -y badvpn-bin 2>/dev/null || {
        # Build from source if not in repo
        cd /tmp
        git clone --depth=1 https://github.com/ambrop72/badvpn.git 2>/dev/null
        if [[ -d badvpn ]]; then
            cd badvpn
            cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 >/dev/null 2>&1
            make >/dev/null 2>&1
            cp udpgw/badvpn-udpgw /usr/local/bin/ 2>/dev/null
            cd /tmp && rm -rf badvpn
        fi
    }
    ok "badvpn-udpgw: $(which badvpn-udpgw 2>/dev/null || echo 'not found')"

    # Install Xray
    info "Installing Xray core (latest)..."
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data 2>&1 | tail -2
    ok "Xray installed: $(xray version 2>/dev/null | head -1 || echo 'check /usr/local/bin/xray')"

    local END_TIME=$(date +%s)
    info "Package installation took $(secs_to_human $((END_TIME - START_TIME)))"
}
