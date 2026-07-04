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
    cat > /etc/bot/.bot.db <<EOF
#bot# $ADMIN_ID $BOT_TOKEN
EOF
    chmod 600 /etc/bot/.bot.db

    # Test notification
    local IP=$(get_ip)
    local DOMAIN=$(cat /etc/xray/domain)
    local TEXT="<b>✅ INSTALASI BERHASIL</b>%0A%0A<b>IP:</b> $IP%0A<b>Domain:</b> $DOMAIN%0A<b>Script:</b> ST-PUSAT CLEAN"

    curl -s --max-time 10 "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${ADMIN_ID}&text=${TEXT}&parse_mode=html" >/dev/null

    ok "Telegram bot configured & test message sent"
}

# Send notification from scripts
tg_send() {
    local BOT_DB="/etc/bot/.bot.db"
    if [[ ! -f "$BOT_DB" ]]; then return; fi

    local CHATID=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 3)
    local KEY=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 2)

    if [[ -z "$CHATID" || -z "$KEY" ]]; then return; fi

    curl -s --max-time 10 "https://api.telegram.org/bot${KEY}/sendMessage" \
        -d "chat_id=${CHATID}&text=$1&parse_mode=html" >/dev/null
}
