#!/bin/bash
# Update script from GitHub
REPO="https://raw.githubusercontent.com/Arya-Blitar22/st-pusat/main"
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'

echo -e "${YELLOW}Updating ST-PUSAT CLEAN...${NC}"
cd /tmp
wget -q "${REPO}/setup.sh" -O setup.sh.new 2>/dev/null && {
    chmod +x setup.sh.new
    # Just copy the new setup.sh and library files if needed
    echo -e "${GREEN}Update downloaded. Run 'bash /tmp/setup.sh.new' to reinstall${NC}"
} || {
    echo -e "${RED}Update failed. Check internet.${NC}"
}
