#!/bin/bash
# ST-PUSAT CLEAN - Main Menu
source /etc/st-pusat/lib/colors.sh 2>/dev/null || source <(wget -qO- https://raw.githubusercontent.com/Arya-Blitar22/st-pusat/main/lib/colors.sh 2>/dev/null) || true

# Colors fallback
NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'

show_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}         ST-PUSAT CLEAN MENU            ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    local total=$(grep -c "^### " /etc/xray/config.json 2>/dev/null || echo 0)
    local exp=$(grep -c "^#& " /etc/xray/config.json 2>/dev/null || echo 0)
    echo -e "  ${GREEN}Users:${NC} $total  ${GREEN}Expired:${NC} $exp"
    echo ""
    echo "  1) SSH Management"
    echo "  2) VMess Management"
    echo "  3) VLESS Management"
    echo "  4) Trojan Management"
    echo "  5) Shadowsocks Management"
    echo "  6) System Settings"
    echo "  7) Backup & Restore"
    echo "  8) Telegram Bot"
    echo "  9) Network & Bandwidth"
    echo "  10) Check All Users"
    echo "  11) Fix Certificate"
    echo "  12) Clear Logs"
    echo "  13) Restart Services"
    echo "  14) Update Script"
    echo ""
    echo -e "  ${RED}0) Exit${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "$(echo -e ${YELLOW}"➤${NC} Select [0-14]: ")" opt
    case $opt in
        1) ssh-menu ;;
        2) vmess-menu ;;
        3) vless-menu ;;
        4) trojan-menu ;;
        5) ss-menu ;;
        6) system-menu ;;
        7) backup-menu ;;
        8) telegram-menu ;;
        9) bw ;;
        10) cek-user ;;
        11) fixcert ;;
        12) clearlog ;;
        13) restart ;;
        14) update ;;
        0) exit 0 ;;
        *) show_menu ;;
    esac
}

# Protocol-specific menus
ssh-menu() {
    clear
    echo -e "${CYAN}━━━━ SSH MANAGEMENT ━━━━${NC}"
    echo "  1) Add SSH User"
    echo "  2) Delete SSH User"
    echo "  3) Check SSH Users"
    echo "  4) Lock SSH User"
    echo "  5) Unlock SSH User"
    echo "  6) Back"
    read -p "Select: " opt
    case $opt in
        1) add-ssh ;;
        2) del-ssh ;;
        3) cek-ssh ;;
        4) lock-ssh ;;
        5) unlock-ssh ;;
    esac
    ssh-menu
}

vmess-menu() {
    clear
    echo -e "${CYAN}━━━━ VMESS MANAGEMENT ━━━━${NC}"
    echo "  1) Add VMess User"
    echo "  2) Delete VMess User"
    echo "  3) Check VMess Users"
    echo "  4) Renew VMess User"
    echo "  5) Back"
    read -p "Select: " opt
    case $opt in
        1) add-vmess ;;
        2) del-vmess ;;
        3) cek-vmess ;;
        4) renew-vmess ;;
    esac
    vmess-menu
}

vless-menu() {
    clear
    echo -e "${CYAN}━━━━ VLESS MANAGEMENT ━━━━${NC}"
    echo "  1) Add VLESS User"
    echo "  2) Delete VLESS User"
    echo "  3) Check VLESS Users"
    echo "  4) Renew VLESS User"
    echo "  5) Back"
    read -p "Select: " opt
    case $opt in
        1) add-vless ;;
        2) del-vless ;;
        3) cek-vless ;;
        4) renew-vless ;;
    esac
    vless-menu
}

trojan-menu() {
    clear
    echo -e "${CYAN}━━━━ TROJAN MANAGEMENT ━━━━${NC}"
    echo "  1) Add Trojan User"
    echo "  2) Delete Trojan User"
    echo "  3) Check Trojan Users"
    echo "  4) Renew Trojan User"
    echo "  5) Back"
    read -p "Select: " opt
    case $opt in
        1) add-trojan ;;
        2) del-trojan ;;
        3) cek-trojan ;;
        4) renew-trojan ;;
    esac
    trojan-menu
}

ss-menu() {
    clear
    echo -e "${CYAN}━━━━ SHADOWSOCKS MANAGEMENT ━━━━${NC}"
    echo "  1) Add Shadowsocks User"
    echo "  2) Delete Shadowsocks User"
    echo "  3) Check Shadowsocks Users"
    echo "  4) Renew Shadowsocks User"
    echo "  5) Back"
    read -p "Select: " opt
    case $opt in
        1) add-ss ;;
        2) del-ss ;;
        3) cek-ss ;;
        4) renew-ss ;;
    esac
    ss-menu
}

# Main loop
while true; do
    show_menu
done
