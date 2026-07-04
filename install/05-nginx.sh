#!/bin/bash
# Nginx setup
setup_nginx() {
    section "NGINX REVERSE PROXY"

    local domain=$(cat /etc/xray/domain)

    # Ensure nginx directory
    mkdir -p /etc/nginx/conf.d

    # Generate xray.conf from template
    sed "s/__DOMAIN__/$domain/g" "$BASE_DIR/config/nginx/xray.conf" > /etc/nginx/conf.d/xray.conf

    # Remove default site
    rm -f /etc/nginx/sites-enabled/default 2>/dev/null

    # Ensure nginx.conf includes conf.d
    if ! grep -q "conf.d/\*\.conf" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/http {/a\    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
    fi
    if ! grep -q "sites-enabled/\*" /etc/nginx/nginx.conf 2>/dev/null; then
        sed -i '/include \/etc\/nginx\/conf.d\/\*\.conf;/a\    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
    fi

    # Test nginx config
    if nginx -t 2>&1 | grep -q "syntax is ok"; then
        systemctl enable nginx 2>/dev/null
        systemctl restart nginx
        ok "Nginx configured with SSL for $domain"
    else
        error "Nginx config error: $(nginx -t 2>&1)"
        exit 1
    fi
}
