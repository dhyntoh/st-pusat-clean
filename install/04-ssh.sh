#!/bin/bash
# SSH & Dropbear setup
setup_ssh() {
    section "SSH & DROPBEAR"

    # SSHD config
    backup_file /etc/ssh/sshd_config
    cp "$BASE_DIR/config/ssh/sshd_config" /etc/ssh/sshd_config
    chmod 600 /etc/ssh/sshd_config
    ok "SSHD configured (ports: 22, 2222, 2223)"

    # Issue/banner
    cp "$BASE_DIR/config/other/issue.net" /etc/issue.net
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

    systemctl restart ssh
    ok "OpenSSH restarted"

    # Dropbear
    if cmd_exists dropbear; then
        backup_file /etc/default/dropbear
        cp "$BASE_DIR/config/ssh/dropbear.conf" /etc/default/dropbear
        systemctl enable dropbear 2>/dev/null
        systemctl restart dropbear 2>/dev/null
        ok "Dropbear configured (ports: 109, 143)"
    else
        warn "Dropbear not installed, skipping"
    fi

    # Password policy
    cp "$BASE_DIR/config/ssh/common-password" /etc/pam.d/common-password 2>/dev/null || {
        cat > /etc/pam.d/common-password <<'EOF'
password sufficient pam_unix.so sha512
password required pam_deny.so
EOF
    }
    ok "Password policy set"
}
