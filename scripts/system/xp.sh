#!/bin/bash
# Expiry checker - runs daily via cron
XRAY_CONFIG="/etc/xray/config.json"
NOW=$(date +%s)

# Check and remove expired users from all protocols
for proto in vmess vless trojan shadowsocks; do
    DB="/etc/$proto/.$proto.db"
    [[ ! -f "$DB" ]] && continue

    grep "^### " "$DB" 2>/dev/null | while IFS=' ' read -r mark user exp rest; do
        EXP_SEC=$(date -d "$exp" +%s 2>/dev/null)
        if [[ $EXP_SEC -lt $NOW ]]; then
            # Remove from xray config
            case $proto in
                vmess) marker="^### $user" ;;
                vless) marker="^#& $user" ;;
                trojan) marker="^#! $user" ;;
                shadowsocks) marker="^#@ $user" ;;
            esac
            sed -i "/${marker} .*/,/},{/d" "$XRAY_CONFIG"
            sed -i "/${marker} /d" "$DB"
            rm -f "/etc/kyt/limit/$proto/ip/$user"
            rm -f "/etc/limit/$proto/$user"

            # Telegram notification
            source /etc/st-pusat/lib/telegram.sh 2>/dev/null || true
            tg_send "<b>⏰ USER EXPIRED</b>%0A<b>User:</b> $user%0A<b>Protocol:</b> $proto%0A<b>Expired:</b> $exp"
        fi
    done
done

# Check SSH users
awk -F: '$3>=1000 && $7~/\/(false|nologin)/ {print $1}' /etc/passwd | while IFS= read -r user; do
    exp=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2)
    if [[ "$exp" != " never" && -n "$exp" ]]; then
        exp_sec=$(date -d "$exp" +%s 2>/dev/null)
        if [[ $exp_sec -lt $NOW ]]; then
            userdel -f "$user" 2>/dev/null
            sed -i "/^### $user /d" /etc/ssh/.ssh.db
        fi
    fi
done

systemctl restart xray 2>/dev/null
