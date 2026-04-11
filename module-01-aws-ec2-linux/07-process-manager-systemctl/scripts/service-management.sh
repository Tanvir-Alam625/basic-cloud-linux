#!/bin/bash
# service-management.sh
# Demonstrates common systemctl service management tasks.
# Run this on your EC2 instance after nginx is installed.
#
# Usage: bash service-management.sh

set -e

SERVICE="nginx"

echo "========================================"
echo " systemctl Demo: Managing $SERVICE"
echo "========================================"
echo ""

echo "1. Checking if $SERVICE is installed..."
if ! command -v nginx &>/dev/null; then
  echo "   nginx not found. Installing..."
  sudo apt update -q
  sudo apt install -y nginx
fi
echo "   nginx is installed."
echo ""

echo "2. Current status:"
sudo systemctl status "$SERVICE" --no-pager -l | head -10
echo ""

echo "3. Is it active?"
sudo systemctl is-active "$SERVICE"
echo ""

echo "4. Is it enabled at boot?"
sudo systemctl is-enabled "$SERVICE"
echo ""

echo "5. Stopping $SERVICE..."
sudo systemctl stop "$SERVICE"
echo "   Status: $(sudo systemctl is-active $SERVICE)"
echo ""

echo "6. Starting $SERVICE..."
sudo systemctl start "$SERVICE"
echo "   Status: $(sudo systemctl is-active $SERVICE)"
echo ""

echo "7. Testing HTTP response..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost
echo ""

echo "8. Last 5 log entries for $SERVICE:"
sudo journalctl -u "$SERVICE" -n 5 --no-pager
echo ""

echo "========================================"
echo " Done!"
echo "========================================"
