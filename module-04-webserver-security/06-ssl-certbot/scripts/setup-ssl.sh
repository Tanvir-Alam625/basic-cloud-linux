#!/bin/bash
# setup-ssl.sh
# Automates Certbot SSL installation for nginx on Ubuntu 22.04.
# Run this AFTER your domain's DNS A record points to this server.
#
# Usage: sudo bash setup-ssl.sh yourdomain.com you@email.com

set -e

DOMAIN="${1:-}"
EMAIL="${2:-}"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "Usage: sudo bash setup-ssl.sh yourdomain.com you@email.com"
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Run with sudo: sudo bash setup-ssl.sh"
  exit 1
fi

echo "Setting up SSL for: $DOMAIN"
echo "Contact email: $EMAIL"
echo ""

# Step 1: Verify domain resolves to this server
echo "1. Checking DNS resolution..."
SERVER_IP=$(curl -s -4 https://checkip.amazonaws.com 2>/dev/null || echo "unknown")
DOMAIN_IP=$(dig +short "$DOMAIN" A | tail -1)

echo "   Server IP: $SERVER_IP"
echo "   Domain IP: $DOMAIN_IP"

if [ "$SERVER_IP" != "$DOMAIN_IP" ]; then
  echo "   WARNING: Domain does not point to this server."
  echo "   Update your DNS A record before running certbot."
  echo "   Continuing anyway — certbot will fail if DNS is wrong."
fi

# Step 2: Install certbot
echo ""
echo "2. Installing certbot..."
apt update -q
apt install -y certbot python3-certbot-nginx

# Step 3: Open port 443 in UFW if it's active
echo ""
echo "3. Checking UFW..."
if ufw status | grep -q "Status: active"; then
  ufw allow 443/tcp
  echo "   Port 443 allowed in UFW."
else
  echo "   UFW is inactive — skipping."
fi

# Step 4: Run certbot
# NOTE: www.$DOMAIN is included only if it also has a DNS A record pointing
# to this server. If your domain is a subdomain (e.g. app.example.com) and
# www.app.example.com has no DNS record, remove "-d www.$DOMAIN" below.
echo ""
echo "4. Running certbot..."
echo "   Verifying www.$DOMAIN resolves to this server..."
WWW_IP=$(dig +short "www.$DOMAIN" A | tail -1)
if [ "$WWW_IP" = "$SERVER_IP" ]; then
  echo "   www.$DOMAIN resolves correctly — including in certbot request."
  certbot --nginx \
    -d "$DOMAIN" \
    -d "www.$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --non-interactive \
    --redirect
else
  echo "   www.$DOMAIN does not resolve to this server (got: ${WWW_IP:-none})."
  echo "   Requesting certificate for $DOMAIN only."
  certbot --nginx \
    -d "$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --non-interactive \
    --redirect
fi

# Step 5: Test renewal
echo ""
echo "5. Testing auto-renewal..."
certbot renew --dry-run

echo ""
echo "========================================"
echo " SSL certificate installed successfully!"
echo " https://$DOMAIN"
echo "========================================"
