#!/bin/bash
# ufw-setup.sh
# Configures UFW with standard rules for a web server.
# Safe to run on a fresh Ubuntu 22.04 instance.
#
# Usage: sudo bash ufw-setup.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Run this script with sudo: sudo bash ufw-setup.sh"
  exit 1
fi

echo "Configuring UFW for a web server..."
echo ""

# Set default policies
ufw default deny incoming
ufw default allow outgoing
echo "  Defaults set: deny incoming, allow outgoing"

# Allow SSH — always do this before enabling
ufw allow 22/tcp
echo "  Allowed: SSH (port 22)"

# Allow HTTP and HTTPS
ufw allow 80/tcp
echo "  Allowed: HTTP (port 80)"

ufw allow 443/tcp
echo "  Allowed: HTTPS (port 443)"

# Enable UFW non-interactively
ufw --force enable
echo ""
echo "UFW enabled and active."
echo ""

# Show final status
ufw status verbose
