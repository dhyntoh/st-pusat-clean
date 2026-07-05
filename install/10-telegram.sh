#!/bin/bash
# Telegram bot setup
setup_telegram() {
    section "TELEGRAM BOT (OPTIONAL)"

    if ! confirm "Setup Telegram bot notifications?"; then
        info "Skipping Telegram setup"
        return
    fi

    prompt "Enter Telegram Bot Token (from @BotFather):" BOT_TOKEN
    prompt "Enter your Telegram User ID:" ADMIN_ID

    if [[ -z "$BOT_TOKEN" || -z "$ADMIN_ID" ]]; then
        warn "Invalid input, skipping Telegram"
        return
    fi

    # Store credentials
    mkdir -p /etc/bot
    cat > /etc/bot/.bot.db <<EOF
#bot# $ADMIN_ID $BOT_TOKEN
EOF
    chmod 600 /etc/bot/.bot.db

    # Create cron-based notification (auto-starts after reboot via cron)
    systemctl enable cron 2>/dev/null

    # Also create a simple systemd oneshot that runs on boot
    cat > /etc/systemd/system/tg-notify.service <<'SERVICE'
[Unit]
Description=Telegram Notifications (ST-PUSAT)
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/limit-ip
ExecStart=/usr/local/sbin/quota
User=root

[Install]
WantedBy=multi-user.target
SERVICE
    systemctl daemon-reload
    systemctl enable tg-notify.service 2>/dev/null || true

    # Enable cron-based notifications (already handled by cron)
    ok "Telegram bot configured"

    # Send test message
    local IP=$(get_ip)
    local DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "-")
    local TEXT="<b>INSTALASI BERHASIL</b>%0A<b>IP:</b> $IP%0A<b>Domain:</b> $DOMAIN"
    curl -s --max-time 10 "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${ADMIN_ID}&text=${TEXT}&parse_mode=html" >/dev/null
    ok "Test message sent"
}

tg_send() {
    local BOT_DB="/etc/bot/.bot.db"
    [[ ! -f "$BOT_DB" ]] && return
    local CHATID=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 3)
    local KEY=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 2)
    [[ -z "$CHATID" || -z "$KEY" ]] && return
    curl -s --max-time 10 "https://api.telegram.org/bot${KEY}/sendMessage" \
        -d "chat_id=${CHATID}&text=$1&parse_mode=html" >/dev/null
}
