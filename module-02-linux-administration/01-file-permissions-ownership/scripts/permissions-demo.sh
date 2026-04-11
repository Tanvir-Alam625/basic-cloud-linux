#!/bin/bash
# permissions-demo.sh
# Demonstrates file permissions and ownership with clear output.
# Run this on your EC2 instance.
#
# Usage: bash permissions-demo.sh

set -e

DEMO_DIR="/tmp/permissions-demo"

echo "========================================"
echo " File Permissions Demo"
echo "========================================"
echo ""

# Clean up any previous run
rm -rf "$DEMO_DIR"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

echo "--- Creating test files ---"
touch public.html secret.env script.sh

echo "" 
echo "Default permissions after touch:"
ls -la

echo ""
echo "--- Setting appropriate permissions ---"

# Public web file: everyone can read, only owner writes
chmod 644 public.html
echo "public.html → 644 (rw-r--r--):"
ls -l public.html

# Secret file: only owner can access
chmod 600 secret.env
echo "secret.env  → 600 (rw-------):"
ls -l secret.env

# Executable script: owner and group can execute
chmod 755 script.sh
echo "script.sh   → 755 (rwxr-xr-x):"
ls -l script.sh

echo ""
echo "--- Demonstrating chown ---"
echo "Current owner of public.html: $(ls -l public.html | awk '{print $3, $4}')"
# sudo chown www-data:www-data public.html  # uncomment to actually change
echo "(run 'sudo chown www-data:www-data public.html' to change to web server user)"

echo ""
echo "--- Numeric to symbolic conversion ---"
for perm in 400 600 644 755 777; do
  touch "test_$perm"
  chmod "$perm" "test_$perm"
  symbolic=$(ls -l "test_$perm" | awk '{print $1}')
  echo "  $perm  →  $symbolic"
  rm "test_$perm"
done

echo ""
echo "--- Cleanup ---"
cd /tmp
rm -rf "$DEMO_DIR"
echo "Demo directory removed."

echo ""
echo "========================================"
echo " Done!"
echo "========================================"
