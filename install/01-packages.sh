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

    info "Installing base packages..."

    # Fix any held packages from previous installations
    if dpkg -l dropbear-bin 2>/dev/null | grep -q "^h"; then
        apt-mark unhold dropbear-bin 2>/dev/null
    fi

    # Install packages - if a package fails, show the error and investigate
    local failed=0
    install_pkg() {
        if ! apt install -y "$1" 2>&1; then
            warn "FAILED: $1 - $(apt policy "$1" 2>/dev/null | grep 'Candidate:' | head -1)"
            ((failed++)) || true
        fi
        return 0
    }

    install_pkg nginx
    install_pkg stunnel4
    install_pkg openssl
    install_pkg dropbear
    install_pkg cron
    install_pkg socat
    install_pkg zip
    install_pkg unzip
    install_pkg wget
    install_pkg curl
    install_pkg jq
    install_pkg vnstat
    install_pkg bc
    install_pkg screen
    install_pkg git
    install_pkg ca-certificates
    install_pkg gnupg
    install_pkg iptables
    install_pkg iptables-persistent
    install_pkg netfilter-persistent
    install_pkg net-tools
    install_pkg dnsutils
    install_pkg lsb-release
    install_pkg fail2ban
    install_pkg uuid-runtime
    install_pkg build-essential
    install_pkg python3
    install_pkg python3-pip
    install_pkg cmake

    # Optional
    for pkg in ruby whois rclone netcat-openbsd; do
        install_pkg "$pkg" || true
    done

    # BadVPN UDPGW
    if apt install -y badvpn-bin 2>/dev/null || apt install -y badvpn 2>/dev/null; then
        ok "badvpn-udpgw from apt"
    else
        info "Building badvpn from source..."
        cd /tmp
        rm -rf badvpn
        git clone --depth=1 https://github.com/ambrop72/badvpn.git 2>/dev/null
        if [[ -d badvpn ]]; then
            cd badvpn
            cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &>/dev/null
            make &>/dev/null
            cp udpgw/badvpn-udpgw /usr/local/bin/ 2>/dev/null
            cd / && rm -rf /tmp/badvpn
            ok "badvpn built from source"
        else
            warn "badvpn not available"
        fi
    fi

    # Xray Core (latest version)
    info "Installing Xray core (latest)..."
    local XRAY_OUTPUT
    XRAY_OUTPUT=$(bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data 2>&1)
    if command -v xray &>/dev/null; then
        ok "Xray: $(xray version 2>/dev/null | head -1)"
    else
        error "Xray installation failed!"
        echo "$XRAY_OUTPUT"
        exit 1
    fi

    local END_TIME=$(date +%s)
    ok "Package installation complete ($(secs_to_human $((END_TIME - START_TIME)))${failed:+ - $failed packages failed})"
}
