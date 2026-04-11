#!/bin/bash
# deploy-app.sh
# Deploys the portfolio website HTML to /var/www/portfolio and
# activates the nginx virtual host config.
#
# Usage: bash deploy-app.sh [domain]
# Example: bash deploy-app.sh yourdomain.com

set -e

DOMAIN="${1:-aws-basic.ostaddevops.click}"
WEB_ROOT="/var/www/portfolio"
NGINX_CONF="/etc/nginx/sites-available/portfolio"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HTML_DIR="$REPO_ROOT/html"
CONFIGS_DIR="$REPO_ROOT/configs"

echo "========================================"
echo " Deploy: Portfolio Website"
echo " Domain: $DOMAIN"
echo "========================================"
echo ""

# Step 1: Verify source files exist
echo "[1/5] Checking source files..."
if [ ! -f "$HTML_DIR/index.html" ]; then
  echo "ERROR: $HTML_DIR/index.html not found."
  echo "Run this script from the module-05-mini-project directory."
  exit 1
fi
echo "      Source files found."

# Step 2: Create web root if it doesn't exist
echo "[2/5] Ensuring web root exists..."
sudo mkdir -p "$WEB_ROOT"

# Step 3: Copy HTML files
echo "[3/5] Copying HTML files to $WEB_ROOT..."
sudo cp "$HTML_DIR/index.html" "$WEB_ROOT/index.html"
sudo cp "$HTML_DIR/style.css"  "$WEB_ROOT/style.css"
sudo chown -R www-data:www-data "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"
echo "      Files deployed:"
ls -lh "$WEB_ROOT"

# Step 4: Write an HTTP-only nginx config and activate it
#
# WHY HTTP-ONLY:
# Certbot verifies domain ownership by making an HTTP request to:
#   http://<domain>/.well-known/acme-challenge/<token>
# nginx must be UP and serving HTTP BEFORE certbot runs.
# If the config already contains ssl_certificate directives pointing at
# cert files that don't exist yet, nginx -t will refuse to load the
# config entirely — certbot can never run.
# We deploy HTTP-only here; certbot --nginx will add the HTTPS block
# and the HTTP→HTTPS redirect automatically.
echo ""
echo "[4/5] Configuring nginx for $DOMAIN (HTTP only — Certbot adds HTTPS next)..."
sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN;

    root /var/www/portfolio;
    index index.html index.htm;

    access_log /var/log/nginx/portfolio-access.log;
    error_log  /var/log/nginx/portfolio-error.log warn;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)\$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location ~ /\. {
        deny all;
    }
}
EOF

# Deactivate default site, activate portfolio
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/portfolio

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
echo "      nginx configured for $DOMAIN"

# Step 5: Verify
echo ""
echo "[5/5] Verifying..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
echo "      HTTP $HTTP_CODE from localhost"

if [ "$HTTP_CODE" -eq 200 ]; then
  echo ""
  echo "========================================"
  echo " Deployment successful!"
  echo " Visit: http://$DOMAIN"
  echo ""
  echo " Next: set up SSL with:"
  echo "   sudo certbot --nginx -d $DOMAIN"
  echo "========================================"
else
  echo "WARNING: Unexpected HTTP status $HTTP_CODE — check nginx logs:"
  echo "  sudo journalctl -u nginx -n 20"
fi
