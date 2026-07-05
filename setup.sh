#!/bin/bash
# ST-PUSAT CLEAN - Full autoscript installer
# Pure shell, no binary obfuscation
# Compatible: Debian 10-13, Ubuntu 20-25
#
# Usage:
#   apt update && apt upgrade -y
#   wget -q https://raw.githubusercontent.com/dhyntoh/st-pusat-clean/master/setup.sh
#   chmod +x setup.sh && ./setup.sh
set -euo pipefail

REPO_ZIP="https://github.com/dhyntoh/st-pusat-clean/archive/master.tar.gz"
INSTALL_DIR="/opt/st-pusat-clean"

# If running standalone (only setup.sh downloaded, no lib/ or install/)
if [[ ! -d "$(dirname "$0")/lib" ]] && [[ ! -d "$(dirname "$0")/install" ]]; then
    clear; echo "ST-PUSAT CLEAN INSTALLER"; echo "Downloading package..."
    rm -rf "$INSTALL_DIR" /tmp/st-pusat-clean.tmp 2>/dev/null
    mkdir -p /tmp/st-pusat-clean.tmp
    cd /tmp/st-pusat-clean.tmp
    wget -q "$REPO_ZIP" -O repo.tar.gz
    tar xzf repo.tar.gz
    cd st-pusat-clean-*
    mkdir -p "$INSTALL_DIR"
    cp -a . "$INSTALL_DIR"
    cd /
    rm -rf /tmp/st-pusat-clean.tmp
    exec bash "$INSTALL_DIR/setup.sh" "$@"
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR

source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/install/00-precheck.sh"
source "$BASE_DIR/install/01-packages.sh"
source "$BASE_DIR/install/02-directories.sh"
source "$BASE_DIR/install/03-domain.sh"
source "$BASE_DIR/install/04-ssh.sh"
source "$BASE_DIR/install/05-nginx.sh"
source "$BASE_DIR/install/06-xray.sh"
source "$BASE_DIR/install/07-other.sh"
source "$BASE_DIR/install/08-cron.sh"
source "$BASE_DIR/install/10-telegram.sh"
source "$BASE_DIR/install/12-finalize.sh"

trap 'echo -e "${RED}Error on line $LINENO${NC}"; exit 1' ERR

clear
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      ST-PUSAT CLEAN INSTALLER        ║${NC}"
echo -e "${CYAN}║    Pure Shell · No Binary · Secure   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

if [[ $EUID -ne 0 ]]; then error "Must run as root!"; exit 1; fi

mkdir -p /etc/st-pusat/lib /var/lib/kyt
cp "$BASE_DIR/lib/colors.sh" /etc/st-pusat/lib/
cp "$BASE_DIR/lib/utils.sh" /etc/st-pusat/lib/
cp "$BASE_DIR/lib/telegram.sh" /etc/st-pusat/lib/ 2>/dev/null || true

precheck
setup_domain
install_packages
create_dirs
setup_ssl
setup_ssh
setup_nginx
setup_xray
setup_other
setup_cron
setup_telegram
finalize
