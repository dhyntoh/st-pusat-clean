#!/bin/bash
# Backup all user data
BACKUP_DIR="/root/backup"
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'

mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d-%H%M%S)

backup_file() {
    local src=$1 name=$2
    if [[ -f "$src" ]]; then
        cp "$src" "$BACKUP_DIR/${name}_${DATE}"
    fi
}

echo -e "${YELLOW}Backing up...${NC}"

backup_file /etc/xray/config.json "xray-config"
backup_file /etc/vmess/.vmess.db "vmess-db"
backup_file /etc/vless/.vless.db "vless-db"
backup_file /etc/trojan/.trojan.db "trojan-db"
backup_file /etc/shadowsocks/.shadowsocks.db "ss-db"
backup_file /etc/ssh/.ssh.db "ssh-db"
backup_file /etc/bot/.bot.db "bot-db"
backup_file /etc/xray/xray.crt "xray-crt"
backup_file /etc/xray/xray.key "xray-key"

# Tar all
cd "$BACKUP_DIR"
tar czf "backup_${DATE}.tar.gz" ./*"${DATE}" 2>/dev/null
rm -f ./*"${DATE}" 2>/dev/null

echo -e "${GREEN}Backup: ${BACKUP_DIR}/backup_${DATE}.tar.gz${NC}"

# Send to Telegram
source /etc/st-pusat/lib/telegram.sh 2>/dev/null || true
tg_send "<b>BACKUP CREATED</b>%0A${BACKUP_DIR}/backup_${DATE}.tar.gz" 2>/dev/null || true
