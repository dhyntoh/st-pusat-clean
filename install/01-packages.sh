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

    # Essential packages - these must install
    PKGS_CORE="nginx dropbear openssl cron socat zip unzip wget curl jq vnstat"
    apt install -y $PKGS_CORE 2>&1 | tail -1
    ok "Core packages installed"

    # SSL & tools
    PKGS_TOOLS="stunnel4 ca-certificates gnupg lsb-release dnsutils bc screen git"
    apt install -y $PKGS_TOOLS 2>&1 | tail -1 || true
    ok "Tools installed"

    # Network & security
    PKGS_NET="iptables iptables-persistent netfilter-persistent net-tools fail2ban"
    apt install -y $PKGS_NET 2>&1 | tail -1 || true
    ok "Network/security packages installed"

    # Development
    PKGS_DEV="build-essential cmake uuid-runtime"
    apt install -y $PKGS_DEV 2>&1 | tail -1 || true
    ok "Dev packages installed"

    # Python
    PKGS_PY="python3 python3-pip"
    apt install -y $PKGS_PY 2>&1 | tail -1 || true

    # Optional - might not exist in all distros
    PKGS_OPT="ruby whois rclone netcat-traditional"
    for pkg in $PKGS_OPT; do
        apt install -y "$pkg" 2>/dev/null && echo "  $pkg installed" || true
    done

    # lolcat via gem if ruby available
    if command -v gem &>/dev/null && ! command -v lolcat &>/dev/null; then
        gem install lolcat 2>/dev/null && ok "lolcat installed" || true
    fi

    # wondershaper - may not be in repos, try pip or apt
    if ! apt install -y wondershaper 2>/dev/null; then
        pip3 install wondershaper 2>/dev/null || true
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
