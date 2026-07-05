#!/bin/bash
# ST-PUSAT CLEAN - Main Menu
# Format: autoscript SSH umum (kayak aslinya)

NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'

TOTAL_VMESS=$(grep -c "^### " /etc/vmess/.vmess.db 2>/dev/null || echo 0)
TOTAL_VLESS=$(grep -c "^#& " /etc/vless/.vless.db 2>/dev/null || echo 0)
TOTAL_TROJAN=$(grep -c "^#! " /etc/trojan/.trojan.db 2>/dev/null || echo 0)
TOTAL_SS=$(grep -c "^#@ " /etc/shadowsocks/.shadowsocks.db 2>/dev/null || echo 0)
TOTAL_SSH=$(awk -F: '$3>=1000 && $7~/\/(false|nologin)/ {print $1}' /etc/passwd 2>/dev/null | grep -cv "nobody" || echo 0)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "-")
IP=$(curl -s --max-time 2 icanhazip.com 2>/dev/null || echo "-")
ISP=$(curl -s --max-time 2 ipinfo.io/org 2>/dev/null || echo "-")
CITY=$(curl -s --max-time 2 ipinfo.io/city 2>/dev/null || echo "-")
OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "-")
KERNEL=$(uname -r 2>/dev/null || echo "-")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "-")
RAM=$(free -m | awk 'NR==2 {print $2}' 2>/dev/null || echo "-")

clear
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       ★ ST-PUSAT CLEAN MENU ★       ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $OS"
echo -e "${CYAN}║${NC} ${WHITE}Kernel:${NC} $KERNEL"
echo -e "${CYAN}║${NC} ${WHITE}RAM:${NC} ${RAM}MB       ${WHITE}Uptime:${NC} $UPTIME"
echo -e "${CYAN}║${NC} ${WHITE}Domain:${NC} $DOMAIN"
echo -e "${CYAN}║${NC} ${WHITE}IP:${NC} $IP"
echo -e "${CYAN}║${NC} ${WHITE}ISP:${NC} $ISP $CITY"
echo -e "${CYAN}╠══════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${YELLOW}SSH${NC}=${TOTAL_SSH} ${YELLOW}VMESS${NC}=${TOTAL_VMESS} ${YELLOW}VLESS${NC}=${TOTAL_VLESS} ${YELLOW}TROJAN${NC}=${TOTAL_TROJAN} ${YELLOW}SS${NC}=${TOTAL_SS}"
echo -e "${CYAN}╠══════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}01${NC}) Add SSH User         ${YELLOW}10${NC}) Add Shadowsocks"
echo -e "${CYAN}║${NC}  ${YELLOW}02${NC}) Delete SSH User      ${YELLOW}11${NC}) Delete Shadowsocks"
echo -e "${CYAN}║${NC}  ${YELLOW}03${NC}) Add VMess User       ${YELLOW}12${NC}) Check All Users"
echo -e "${CYAN}║${NC}  ${YELLOW}04${NC}) Delete VMess User    ${YELLOW}13${NC}) Renew User"
echo -e "${CYAN}║${NC}  ${YELLOW}05${NC}) Add VLESS User       ${YELLOW}14${NC}) Telegram Bot"
echo -e "${CYAN}║${NC}  ${YELLOW}06${NC}) Delete VLESS User    ${YELLOW}15${NC}) Backup"
echo -e "${CYAN}║${NC}  ${YELLOW}07${NC}) Add Trojan User      ${YELLOW}16${NC}) System Info"
echo -e "${CYAN}║${NC}  ${YELLOW}08${NC}) Delete Trojan User    ${YELLOW}17${NC}) Restart Services"
echo -e "${CYAN}║${NC}  ${YELLOW}09${NC}) Bandwidth Monitor    ${YELLOW}18${NC}) Fix Certificate"
echo -e "${CYAN}║${NC}                      ${YELLOW}00${NC}) Exit"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""
read -p " Select menu [00-18]: " opt
echo ""

case $opt in
    01|1) add-ssh ;;
    02|2) del-ssh ;;
    03|3) add-vmess ;;
    04|4) del-vmess ;;
    05|5) add-vless ;;
    06|6) del-vless ;;
    07|7) add-trojan ;;
    08|8) del-trojan ;;
    09|9) bw ;;
    10) add-ss ;;
    11) del-ss ;;
    12) cek-all ;;
    13) echo ""; echo "  1) Renew VMess  2) Renew VLESS  3) Renew Trojan"
        read -p "  Select: " ropt
        case $ropt in 1) renew-vmess;; 2) renew-vless;; 3) renew-trojan;; esac ;;
    14) echo ""; echo "  1) Setup Bot  2) Delete Bot"
        read -p "  Select: " bopt
        case $bopt in
            1) echo "  Get token from @BotFather on Telegram"
               read -p "  Bot Token: " token
               read -p "  Admin ID: " chatid
               echo "#bot# $chatid $token" > /etc/bot/.bot.db
               chmod 600 /etc/bot/.bot.db
               echo -e "${GREEN}Bot configured${NC}" ;;
            2) rm -f /etc/bot/.bot.db
               echo -e "${RED}Bot deleted${NC}" ;;
        esac ;;
    15) backup ;;
    16) clear; echo -e "${CYAN}━━━━ SYSTEM INFO ━━━━${NC}"
        echo "  OS      : $OS"
        echo "  Kernel  : $KERNEL"
        echo "  RAM     : ${RAM}MB"
        echo "  Uptime  : $UPTIME"
        echo "  IP      : $IP"
        echo "  Domain  : $DOMAIN"
        echo "  ISP     : $ISP $CITY"
        cat /root/log-install.txt 2>/dev/null || echo "No install log" ;;
    17) restart ;;
    18) fixcert ;;
    00|0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
esac

echo ""
read -p " Press Enter to return to menu... "
exec menu
