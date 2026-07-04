#!/bin/bash
# Clear logs
truncate -s 0 /var/log/nginx/access.log 2>/dev/null
truncate -s 0 /var/log/xray/access.log 2>/dev/null
truncate -s 0 /var/log/xray/error.log 2>/dev/null
