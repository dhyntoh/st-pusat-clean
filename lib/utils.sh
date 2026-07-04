#!/bin/bash
# Utility functions

# Generate UUID
gen_uuid() {
    if command -v uuidgen &>/dev/null; then
        uuidgen
    elif [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        python3 -c "import uuid; print(uuid.uuid4())"
    fi
}

# Generate random string
gen_random() {
    tr -dc 'a-zA-Z0-9' </dev/urandom | head -c "${1:-8}"
}

# Generate trojan password
gen_password() {
    openssl rand -base64 16 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=' | head -c 22
}

# Check if command exists
cmd_exists() { command -v "$1" &>/dev/null; }

# Get public IP
get_ip() {
    curl -s --max-time 5 ipinfo.io/ip 2>/dev/null || \
    curl -s --max-time 5 icanhazip.com 2>/dev/null || \
    curl -s --max-time 5 ifconfig.me 2>/dev/null
}

# Get ISP info
get_isp() { curl -s --max-time 5 ipinfo.io/org 2>/dev/null | cut -d' ' -f2-10; }
get_city() { curl -s --max-time 5 ipinfo.io/city 2>/dev/null; }

# Traffic bytes to human readable
bytes_to_human() {
    local bytes=$1
    if [[ $bytes -lt 1024 ]]; then echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then echo "$(( (bytes + 1048575)/1048576 ))MB"
    else echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}

# Date format
date_idn() { date -d "$1" +"%d-%m-%Y"; }
date_exp() { date -d "$1" +"%s"; }

# Seconds to human readable
secs_to_human() {
    local s=$1
    local h=$(( s / 3600 ))
    local m=$(( (s % 3600) / 60 ))
    local sec=$(( s % 60 ))
    echo "${h}h ${m}m ${sec}s"
}

# Backup file with timestamp
backup_file() {
    if [[ -f "$1" ]]; then
        cp "$1" "${1}.bak.$(date +%Y%m%d-%H%M%S)"
    fi
}
