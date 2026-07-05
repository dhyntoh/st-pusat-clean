#!/bin/bash
# Fix existing ST-PUSAT CLEAN installation
# Sync config, fix nginx, add missing users to Xray

echo "Fix 1: Sync Xray config..."
rm -f /etc/xray/config.json
ln -s /usr/local/etc/xray/config.json /etc/xray/config.json

echo "Fix 2: Deploy proper nginx config..."
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "localhost")
sed "s/__DOMAIN__/$DOMAIN/g" /opt/st-pusat-clean/config/nginx/xray.conf > /etc/nginx/conf.d/xray.conf
nginx -t && systemctl reload nginx

echo "Fix 3: Sync users from DB to Xray config..."
python3 << 'PYEOF'
import json

config_path = "/usr/local/etc/xray/config.json"

with open(config_path) as f:
    cfg = json.load(f)

# Read users from DBs and add them to inbounds
def read_users(filepath, prefix, id_field="id"):
    users = []
    try:
        with open(filepath) as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 4 and parts[0] == prefix:
                    users.append({id_field: parts[3], "email": parts[1]})
    except: pass
    return users

vless = read_users("/etc/vless/.vless.db", "#&", "id")
vmess = read_users("/etc/vmess/.vmess.db", "###", "id")
trojan = read_users("/etc/trojan/.trojan.db", "#!", "password")

for inbound in cfg.get("inbounds", []):
    port = inbound.get("port")
    if port == 10001: inbound["settings"]["clients"] = vless
    elif port == 10002: inbound["settings"]["clients"] = [{"id": u["id"],"alterId":0,"email": u["email"]} for u in vmess]
    elif port == 10003: inbound["settings"]["clients"] = trojan

with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)

print(f"  VLESS: {len(vless)}, VMess: {len(vmess)}, Trojan: {len(trojan)}")
PYEOF

systemctl restart xray
sleep 2

echo ""
echo "Fix 4: Verify..."
ss -tlnp | grep -E ":443|xray" | head -5
python3 -c "
import json
with open('/usr/local/etc/xray/config.json') as f:
    cfg = json.load(f)
for i in cfg.get('inbounds',[]):
    c = i.get('settings',{}).get('clients',[])
    if c: print(f'  port={i[\"port\"]}: {len(c)} user(s) - first: {c[0][\"email\"]}')
"
echo ""
echo "Done! Test your connection now."
