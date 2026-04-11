#!/bin/bash
# fix-permissions.sh
# Fixes common SSH key permission issues.
# Run this on your LOCAL machine (not on the server).
#
# Usage: bash fix-permissions.sh ~/.ssh/devops-lab-key.pem

set -e

KEY_FILE="${1:-$HOME/.ssh/devops-lab-key.pem}"

if [ ! -f "$KEY_FILE" ]; then
  echo "ERROR: Key file not found: $KEY_FILE"
  echo "Usage: bash fix-permissions.sh /path/to/your-key.pem"
  exit 1
fi

echo "Current permissions on $KEY_FILE:"
ls -la "$KEY_FILE"

# Set to read-only by owner only (required by SSH)
chmod 400 "$KEY_FILE"

echo ""
echo "Fixed permissions:"
ls -la "$KEY_FILE"

echo ""
echo "Your key is now ready to use with:"
echo "  ssh -i $KEY_FILE ubuntu@YOUR_SERVER_IP"
