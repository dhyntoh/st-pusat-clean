#!/bin/bash
# Pre-installation check
precheck() {
    section "SYSTEM CHECK"

    # Root check
    if [[ $EUID -ne 0 ]]; then
        error "Must run as root!"
        exit 1
    fi
    ok "Root user"

    # OS Check
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
        OS_PRETTY=$PRETTY_NAME
    else
        error "Cannot detect OS"
        exit 1
    fi

    if [[ "$OS_NAME" != "debian" && "$OS_NAME" != "ubuntu" ]]; then
        error "Unsupported OS: $OS_PRETTY"
        exit 1
    fi
    ok "OS: $OS_PRETTY"

    # Debian version check
    if [[ "$OS_NAME" == "debian" && ${OS_VERSION%%.*} -lt 10 ]]; then
        error "Debian $OS_VERSION too old. Need 10+"
        exit 1
    fi
    if [[ "$OS_NAME" == "ubuntu" && ${OS_VERSION%%.*} -lt 20 ]]; then
        error "Ubuntu $OS_VERSION too old. Need 20+"
        exit 1
    fi

    # Architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
        error "Architecture $ARCH not supported"
        exit 1
    fi
    ok "Architecture: $ARCH"

    # Virtualization check
    if systemd-detect-virt 2>/dev/null | grep -qi "openvz"; then
        error "OpenVZ not supported"
        exit 1
    fi
    ok "Virtualization: $(systemd-detect-virt 2>/dev/null || echo 'none/unknown')"

    # IP detection
    IP=$(get_ip)
    if [[ -z "$IP" ]]; then
        error "Cannot detect IP address"
        exit 1
    fi
    ok "IP Address: $IP"
    echo "$IP" > /etc/xray/ipvps

    # Memory
    local mem_total=$(free -m | awk '/Mem:/ {print $2}')
    ok "RAM: ${mem_total}MB"

    # Disk
    local disk_avail=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $disk_avail -lt 1 ]]; then
        error "Disk space too low: ${disk_avail}GB"
        exit 1
    fi
    ok "Disk: ${disk_avail}GB available"

    return 0
}
