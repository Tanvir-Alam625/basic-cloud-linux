#!/bin/bash
# setup-server.sh
# Fully provisions a fresh Ubuntu 22.04 EC2 instance for web hosting.
# Installs tools, configures UFW, installs nginx, and sets up certbot.
#
# Run once on a fresh instance:
#   bash setup-server.sh
#
# This script is idempotent — safe to run multiple times.

set -e

echo "========================================"
echo " Server Setup — DevOps Mini Project"
echo " $(date)"
echo "========================================"
echo ""

# Step 1: Update package index and upgrade
echo "[1/6] Updating packages..."
sudo apt update -q
sudo apt upgrade -y -q
echo "      Done."

# Step 2: Install required packages
# NOTE: bash line continuation (\) must be the very last character on the
# line — no spaces or comments after it. Inline comments break apt install.
echo "[2/6] Installing packages..."
sudo apt install -y \
  curl \
  wget \
  git \
  unzip \
  nginx \
  certbot \
  python3-certbot-nginx \
  ufw \
  htop \
  jq
echo "      Done."

# Step 3: Configure UFW firewall
echo "[3/6] Configuring UFW..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp          # SSH
sudo ufw allow 80/tcp          # HTTP
sudo ufw allow 443/tcp         # HTTPS
sudo ufw --force enable
echo "      UFW enabled. Rules:"
sudo ufw status | grep "ALLOW"

# Step 4: Enable and start nginx
echo ""
echo "[4/6] Configuring nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
echo "      nginx is running. HTTP response: $HTTP_CODE"

# Step 5: Create web root directory
echo ""
echo "[5/6] Creating web root..."
sudo mkdir -p /var/www/portfolio
sudo chown -R ubuntu:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio
echo "      /var/www/portfolio created."

# Step 6: Summary
echo ""
echo "[6/6] Setup complete!"
echo ""
echo "========================================"
echo " Summary"
echo "========================================"
echo ""
echo "  Server IP:  $(curl -s https://checkip.amazonaws.com)"
echo "  Nginx:      $(nginx -v 2>&1)"
echo "  Certbot:    $(certbot --version 2>&1)"
echo "  UFW:        $(sudo ufw status | head -1)"
echo ""
echo "Next steps:"
echo "  1. Deploy your site: bash deploy-app.sh"
echo "  2. Set up DNS (Route53 A record → this IP)"
echo "  3. Configure nginx server_name in /etc/nginx/sites-available/portfolio"
echo "  4. Install SSL: sudo certbot --nginx -d aws-basic.ostaddevops.click"
echo "========================================"
