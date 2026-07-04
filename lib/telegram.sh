#!/bin/bash
# Telegram notification functions
tg_send() {
    local BOT_DB="/etc/bot/.bot.db"
    [[ ! -f "$BOT_DB" ]] && return
    local CHATID=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 3)
    local KEY=$(grep -E "^#bot# " "$BOT_DB" | cut -d ' ' -f 2)
    [[ -z "$CHATID" || -z "$KEY" ]] && return
    curl -s --max-time 10 "https://api.telegram.org/bot${KEY}/sendMessage" \
        -d "chat_id=${CHATID}&text=$1&parse_mode=html" >/dev/null
}
