#!/bin/bash
# cron-examples.sh
# Creates example cron jobs demonstrating common DevOps patterns.
# Run this to see what your crontab looks like with real-world examples.
# This script SHOWS examples — it does not automatically add them to your crontab.
#
# Usage: bash cron-examples.sh

echo "========================================"
echo " Example Cron Jobs for a DevOps Server"
echo "========================================"
echo ""
echo "Add these to your crontab with: crontab -e"
echo ""

cat << 'CRONTAB_EXAMPLES'
# ============================================================
# EXAMPLE CRONTAB — Copy and paste these into: crontab -e
# ============================================================

# 1. SSL Certificate Renewal (Let's Encrypt via Certbot)
#    Run twice daily — certbot only renews if expiry is < 30 days
0 0,12 * * *  /usr/bin/certbot renew --quiet >> /var/log/certbot-renew.log 2>&1

# 2. Clean up old temporary files (older than 7 days)
0 1 * * *  find /tmp -type f -mtime +7 -delete >> /var/log/cleanup.log 2>&1

# 3. Disk usage snapshot (runs every 6 hours)
#    Write to ~/logs/ — ubuntu user has no write access to /var/log directly
0 */6 * * *  df -h >> ~/logs/disk-usage.log 2>&1

# 4. Backup nginx configuration (every Sunday at 3 AM)
0 3 * * 0  tar -czf /home/ubuntu/backups/nginx-config-$(date +\%Y\%m\%d).tar.gz /etc/nginx/ 2>/dev/null

# 5. Reload nginx after certificate renewal (daily at 12:05 AM — after certbot runs)
5 0 * * *  /usr/bin/systemctl reload nginx >> /var/log/nginx-reload.log 2>&1

# 6. Server startup event logger
@reboot  echo "Server restarted at $(date)" >> /var/log/boot-events.log

# 7. Remove old log backup files (keep last 30 days of disk-usage logs)
0 2 * * *  find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null

CRONTAB_EXAMPLES

echo ""
echo "To add all of these at once, run:"
echo "  (crontab -l; cat << 'EOF'"
echo "  [paste above]"
echo "  EOF"
echo "  ) | crontab -"
echo ""
echo "To view your current crontab:"
echo "  crontab -l"
