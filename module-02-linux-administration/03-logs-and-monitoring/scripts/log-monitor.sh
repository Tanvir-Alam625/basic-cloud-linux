#!/bin/bash
# log-monitor.sh
# Quick log health check for a web server.
# Prints a summary of errors and key metrics from log files.
#
# Usage: bash log-monitor.sh

set -e

NGINX_ACCESS="/var/log/nginx/access.log"
NGINX_ERROR="/var/log/nginx/error.log"
AUTH_LOG="/var/log/auth.log"

echo "========================================"
echo " Log Monitor — $(date)"
echo "========================================"
echo ""

echo "--- NGINX ACCESS SUMMARY ---"
if [ -f "$NGINX_ACCESS" ]; then
  TOTAL=$(wc -l < "$NGINX_ACCESS")
  ERRORS=$(grep -cE '" [45][0-9]{2} ' "$NGINX_ACCESS" 2>/dev/null || echo 0)
  echo "  Total requests : $TOTAL"
  echo "  4xx/5xx errors : $ERRORS"
  echo ""
  echo "  Top 5 status codes:"
  awk '{print $9}' "$NGINX_ACCESS" | sort | uniq -c | sort -rn | head -5 | \
    while read count code; do echo "    $code : $count requests"; done
else
  echo "  $NGINX_ACCESS not found (nginx may not be installed yet)"
fi

echo ""
echo "--- NGINX ERRORS (last 20 lines) ---"
if [ -f "$NGINX_ERROR" ]; then
  sudo tail -n 20 "$NGINX_ERROR" 2>/dev/null | grep -v "^$" || echo "  No errors found."
else
  echo "  $NGINX_ERROR not found."
fi

echo ""
echo "--- FAILED SSH LOGIN ATTEMPTS (today) ---"
if [ -f "$AUTH_LOG" ]; then
  TODAY=$(date '+%b %e')
  COUNT=$(grep "$TODAY" "$AUTH_LOG" 2>/dev/null | grep -c "Failed\|failure" || echo 0)
  echo "  Failed attempts today: $COUNT"
  if [ "$COUNT" -gt 0 ]; then
    echo "  Recent failures:"
    grep "$TODAY" "$AUTH_LOG" | grep "Failed\|failure" | tail -3 | \
      sed 's/^/    /'
  fi
else
  echo "  $AUTH_LOG not found."
fi

echo ""
echo "--- DISK & MEMORY ---"
echo "  Disk usage:"
df -h / | tail -1 | awk '{printf "    Used: %s / %s (%s)\n", $3, $2, $5}'

echo "  Memory usage:"
free -h | grep "^Mem" | awk '{printf "    Used: %s / %s\n", $3, $2}'

echo ""
echo "========================================"
echo " Done."
echo "========================================"
