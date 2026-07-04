#!/bin/bash
# ST-PUSAT CLEAN - Full autoscript installer
# Pure shell, no binary obfuscation
# Compatible: Debian 10-13, Ubuntu 20-25
set -euo pipefail

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR

# Source libraries
source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/utils.sh"

# Source install modules
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
echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      ST-PUSAT CLEAN INSTALLER        ║${NC}"
echo -e "${CYAN}║    Pure Shell · No Binary · Secure   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Root check early
if [[ $EUID -ne 0 ]]; then error "Must run as root!"; exit 1; fi

# Deploy libraries to system
mkdir -p /etc/st-pusat/lib
cp "$BASE_DIR/lib/colors.sh" /etc/st-pusat/lib/
cp "$BASE_DIR/lib/utils.sh" /etc/st-pusat/lib/
cp "$BASE_DIR/lib/telegram.sh" /etc/st-pusat/lib/ 2>/dev/null || true

# Pre-check
precheck

# Setup
mkdir -p /var/lib/kyt
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
