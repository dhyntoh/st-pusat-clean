#!/bin/bash
echo "Restarting services..."
systemctl restart nginx xray dropbear cron ssh
echo "Done. Check:"
systemctl is-active nginx xray dropbear ssh
