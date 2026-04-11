#!/bin/bash
# commands-cheatsheet.sh
# Run this script on your EC2 instance to see the output of common Linux commands.
# Each section is labeled so you can follow along.
#
# Usage: bash commands-cheatsheet.sh

set -e

echo "========================================"
echo " Linux Commands Cheatsheet Demo"
echo "========================================"
echo ""

echo "--- NAVIGATION ---"
echo "pwd:"; pwd
echo "whoami:"; whoami
echo "hostname:"; hostname
echo ""

echo "--- FILESYSTEM OVERVIEW ---"
echo "ls /:"
ls /
echo ""

echo "--- DISK SPACE (df -h) ---"
df -h
echo ""

echo "--- MEMORY (free -h) ---"
free -h
echo ""

echo "--- UPTIME ---"
uptime
echo ""

echo "--- TOP 5 PROCESSES BY CPU ---"
ps aux --sort=-%cpu | head -6
echo ""

echo "--- NETWORK INTERFACES ---"
ip -brief address
echo ""

echo "--- LISTENING PORTS ---"
ss -tlnp
echo ""

echo "--- RECENT SYSTEM MESSAGES ---"
sudo tail -n 5 /var/log/syslog 2>/dev/null || journalctl -n 5 --no-pager
echo ""

echo "========================================"
echo " Done! All commands ran successfully."
echo "========================================"
