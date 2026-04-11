#!/bin/bash
# install-nginx.sh
# Installs nginx, verifies it's running, and ensures it starts at boot.
#
# Usage: bash install-nginx.sh

set -e

echo "Installing nginx..."
sudo apt update -q
sudo apt install -y nginx

echo "Enabling nginx at boot..."
sudo systemctl enable nginx

echo "Starting nginx..."
sudo systemctl start nginx

echo ""
echo "Status:"
sudo systemctl is-active nginx

echo ""
echo "Listening on port 80:"
ss -tlnp | grep :80

echo ""
echo "Testing HTTP response:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" -eq 200 ]; then
  echo "nginx is installed and serving successfully."
else
  echo "WARNING: Unexpected status code $HTTP_CODE — check logs: sudo journalctl -u nginx -n 20"
fi
