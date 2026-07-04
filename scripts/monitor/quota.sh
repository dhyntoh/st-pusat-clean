#!/bin/bash
# Quota monitoring via Xray API
XRAY_API="127.0.0.1:10000"

bytes_to_human() {
    local bytes=$1
    if [[ $bytes -lt 1024 ]]; then echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then echo "$(( (bytes + 1048575)/1048576 ))MB"
    else echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}

check_proto() {
    local proto=$1 marker=$2 db_path=$3 limit_dir=$4
    local data=($(grep "^${marker} " "$db_path" 2>/dev/null | cut -d' ' -f2 | sort -u))
    [[ ${#data[@]} -eq 0 ]] && return

    mkdir -p "/tmp/quota"

    for user in "${data[@]}"; do
        local stats=$(xray api statsquery --server=$XRAY_API 2>/dev/null | grep -C2 "$user")
        local inb=$(echo "$stats" | grep value | sed -n '1p' | grep -oP '\d+')
        local outb=$(echo "$stats" | grep value | sed -n '2p' | grep -oP '\d+')
        local total=$(( inb + outb ))

        local quota_file="/etc/limit/${proto}/${user}"
        if [[ -f "$quota_file" ]]; then
            local prev=$(cat "$quota_file")
            total=$(( total + prev ))
        fi
        echo "$total" > "$quota_file"

        # Check if quota exceeded
        local limit_str=$(grep "^${marker} $user " "$db_path" 2>/dev/null | awk '{print $5}')
        local limit_gb=${limit_str:-0}
        if [[ $limit_gb -gt 0 ]]; then
            local limit_bytes=$(( limit_gb * 1073741824 ))
            if [[ $total -ge $limit_bytes ]]; then
                # Remove user
                local exp=$(grep "^${marker} $user " "$XRAY_CONFIG" | cut -d' ' -f3)
                sed -i "/^${marker} $user $exp/,/},{/d" /etc/xray/config.json
                sed -i "/^${marker} $user /d" "$db_path"
                rm -f "$quota_file"
                rm -f "/etc/kyt/limit/${proto}/ip/$user"
            fi
        fi

        xray api stats --server=$XRAY_API -name "user>>>${user}>>>traffic>>>downlink" -reset >/dev/null 2>&1
        sleep 0.1
    done
}

XRAY_CONFIG="/etc/xray/config.json"

check_proto "vmess" "###" "/etc/vmess/.vmess.db" "vmess"
check_proto "vless" "#&" "/etc/vless/.vless.db" "vless"
check_proto "trojan" "#!" "/etc/trojan/.trojan.db" "trojan"

systemctl restart xray 2>/dev/null
