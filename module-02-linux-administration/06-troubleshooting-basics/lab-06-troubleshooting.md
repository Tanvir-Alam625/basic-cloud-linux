# Lab 06 — Troubleshooting Basics

## Task 1 — Full Server Health Check

Run this sequence to get a complete picture of a server:

```bash
echo "=== DISK ===" && df -h /
echo ""
echo "=== MEMORY ===" && free -h
echo ""
echo "=== CPU / LOAD ===" && uptime
echo ""
echo "=== TOP 5 PROCESSES BY CPU ===" && ps aux --sort=-%cpu | head -6
echo ""
echo "=== TOP 5 PROCESSES BY MEMORY ===" && ps aux --sort=-%mem | head -6
echo ""
echo "=== LISTENING PORTS ===" && ss -tlnp
echo ""
echo "=== FAILED SERVICES ===" && systemctl list-units --type=service --state=failed
echo ""
echo "=== LAST 10 SYSTEM ERRORS ===" && sudo journalctl -p err -n 10 --no-pager
```

---

## Task 2 — Disk Forensics

```bash
# Find where disk space is going
du -sh /var/log/* 2>/dev/null | sort -rh | head -10

# Check journal size
sudo journalctl --disk-usage

# Check apt cache size
du -sh /var/cache/apt/

# Clean up cache
sudo apt clean
sudo journalctl --vacuum-size=100M  # keep only 100MB of journal

df -h /  # check available space now
```

---

## Task 3 — Port Conflict Simulation

```bash
# What's using port 80?
sudo lsof -i :80

# Try starting a second process on 80 (will fail if nginx is running)
sudo python3 -m http.server 80 &
PYTHON_PID=$!
sleep 1

# Check the error
sudo journalctl -n 5 --no-pager 2>/dev/null || true

# Understand why: port already in use
sudo lsof -i :80

# Clean up
kill "$PYTHON_PID" 2>/dev/null || true
```

---

## Task 4 — Simulate and Fix a Broken Service

```bash
# Step 1: Confirm nginx is running
sudo systemctl status nginx | grep Active

# Step 2: Introduce a config error
echo "this_is_invalid;" | sudo tee /etc/nginx/conf.d/oops.conf

# Step 3: Attempt a config test
sudo nginx -t
# Expected: test failed

# Step 4: Check which file is causing the error
sudo nginx -T 2>&1 | grep -i "error\|emerg" | head -5

# Step 5: Fix it
sudo rm /etc/nginx/conf.d/oops.conf

# Step 6: Verify and restart
sudo nginx -t && sudo systemctl reload nginx
echo "Service recovered!"
```

---

## Task 5 — Build a Troubleshooting Checklist Script

```bash
cat > ~/health-check.sh << 'EOF'
#!/bin/bash
# Quick server health check script

ISSUES=0

# Check disk usage
DISK_USE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USE" -gt 80 ]; then
  echo "WARNING: Disk usage is at ${DISK_USE}% — getting full!"
  ISSUES=$((ISSUES+1))
else
  echo "OK: Disk usage at ${DISK_USE}%"
fi

# Check nginx is running
if systemctl is-active nginx &>/dev/null; then
  echo "OK: nginx is running"
else
  echo "ERROR: nginx is NOT running!"
  ISSUES=$((ISSUES+1))
fi

# Check SSH is running
if systemctl is-active ssh &>/dev/null; then
  echo "OK: SSH is running"
else
  echo "ERROR: SSH is NOT running!"
  ISSUES=$((ISSUES+1))
fi

# Check for failed services
FAILED=$(systemctl list-units --type=service --state=failed --no-legend | wc -l)
if [ "$FAILED" -gt 0 ]; then
  echo "WARNING: $FAILED failed service(s) detected"
  ISSUES=$((ISSUES+1))
else
  echo "OK: No failed services"
fi

echo ""
if [ "$ISSUES" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$ISSUES issue(s) found. Investigate above."
fi
EOF

chmod +x ~/health-check.sh
bash ~/health-check.sh
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
