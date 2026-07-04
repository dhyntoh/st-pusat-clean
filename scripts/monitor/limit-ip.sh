#!/bin/bash
# Multi-login detection via Xray access log
XRAY_LOG="/var/log/xray/access.log"
XRAY_CONFIG="/etc/xray/config.json"
BOT_DB="/etc/bot/.bot.db"

send_tg() {
    local user=$1 iplimit=$2
    [[ ! -f "$BOT_DB" ]] && return
    local CHATID=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 3)
    local KEY=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 2)
    [[ -z "$CHATID" || -z "$KEY" ]] && return
    local TEXT="<b>MULTI-LOGIN DETECTED</b>%0A<b>User:</b> $user%0A<b>Limit:</b> $iplimit IP"
    curl -s --max-time 10 "https://api.telegram.org/bot${KEY}/sendMessage" \
        -d "chat_id=${CHATID}&text=${TEXT}&parse_mode=html" >/dev/null
}

# VMess
echo -n > "$XRAY_LOG"
sleep 0.5
for user in $(ls /etc/kyt/limit/vmess/ip/ 2>/dev/null); do
    iplimit=$(cat "/etc/kyt/limit/vmess/ip/$user" 2>/dev/null)
    unique_ips=$(grep "$user" "$XRAY_LOG" 2>/dev/null | grep -oP 'tcp:\K[0-9.]+' | sort -u | wc -l)
    if [[ $unique_ips -gt $iplimit ]]; then
        exp=$(grep "^### $user " "$XRAY_CONFIG" | cut -d' ' -f3)
        sed -i "/^### $user $exp/,/},{/d" "$XRAY_CONFIG"
        sed -i "/^### $user /d" /etc/vmess/.vmess.db 2>/dev/null
        rm -f "/etc/kyt/limit/vmess/ip/$user"
        send_tg "$user" "$iplimit"
    fi
done

# VLESS
for user in $(ls /etc/kyt/limit/vless/ip/ 2>/dev/null); do
    iplimit=$(cat "/etc/kyt/limit/vless/ip/$user" 2>/dev/null)
    unique_ips=$(grep "$user" "$XRAY_LOG" 2>/dev/null | grep -oP 'tcp:\K[0-9.]+' | sort -u | wc -l)
    if [[ $unique_ips -gt $iplimit ]]; then
        exp=$(grep "^#& $user " "$XRAY_CONFIG" | cut -d' ' -f3)
        sed -i "/^#& $user $exp/,/},{/d" "$XRAY_CONFIG"
        sed -i "/^#& $user /d" /etc/vless/.vless.db 2>/dev/null
        rm -f "/etc/kyt/limit/vless/ip/$user"
        send_tg "$user" "$iplimit"
    fi
done

# Trojan
for user in $(ls /etc/kyt/limit/trojan/ip/ 2>/dev/null); do
    iplimit=$(cat "/etc/kyt/limit/trojan/ip/$user" 2>/dev/null)
    unique_ips=$(grep "$user" "$XRAY_LOG" 2>/dev/null | grep -oP 'tcp:\K[0-9.]+' | sort -u | wc -l)
    if [[ $unique_ips -gt $iplimit ]]; then
        exp=$(grep "^#! $user " "$XRAY_CONFIG" | cut -d' ' -f3)
        sed -i "/^#! $user $exp/,/},{/d" "$XRAY_CONFIG"
        sed -i "/^#! $user /d" /etc/trojan/.trojan.db 2>/dev/null
        rm -f "/etc/kyt/limit/trojan/ip/$user"
        send_tg "$user" "$iplimit"
    fi
done

systemctl restart xray 2>/dev/null
