#!/bin/bash
# env-setup.sh
# Sets up a standard set of environment variables for a DevOps lab server.
# Writes to ~/.bashrc for persistence.
#
# Usage: bash env-setup.sh

set -e

BASHRC="$HOME/.bashrc"
MARKER="# === DevOps Lab Environment Variables ==="

# Check if already added
if grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
  echo "Environment variables already set in $BASHRC"
  echo "Remove the block between the === markers to re-run this script."
  exit 0
fi

echo "Adding environment variables to $BASHRC..."

cat >> "$BASHRC" << EOF

$MARKER
export DEVOPS_LAB=true
export APP_ENV=development
export APP_PORT=3000
export PROJECTS_DIR="\$HOME/projects"
# === End DevOps Lab Environment Variables ===
EOF

echo "Done. Apply now with:"
echo "  source ~/.bashrc"
echo ""
echo "Variables added:"
grep -A 6 "$MARKER" "$BASHRC"
