# Lab 03 — Logs & Monitoring

## Task 1 — Explore Log Files

```bash
# List all files in /var/log with sizes
sudo ls -lh /var/log/ | sort -k5 -rh | head -20

# Find the largest log files
sudo find /var/log -type f -name "*.log" -exec du -sh {} \; 2>/dev/null | sort -rh | head -10
```

---

## Task 2 — SSH Access Audit

```bash
# See all successful SSH logins
sudo grep "Accepted publickey" /var/log/auth.log

# See failed login attempts (important for security)
sudo grep "Failed password\|authentication failure" /var/log/auth.log | tail -10

# See all sudo usage
sudo grep "sudo" /var/log/auth.log | tail -10
```

---

## Task 3 — nginx Request Analysis

Make sure nginx is running and has received some requests.

```bash
# Generate some test traffic
for i in {1..10}; do curl -s http://localhost/ > /dev/null; done
curl -s http://localhost/doesnotexist > /dev/null   # 404
curl -s http://localhost/another-missing > /dev/null # 404

# Now analyze
echo "Total requests:"
wc -l < /var/log/nginx/access.log

echo ""
echo "404 errors:"
grep " 404 " /var/log/nginx/access.log

echo ""
echo "Status code summary:"
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

Expected output:
```
Total requests:
12

404 errors:
127.0.0.1 - - [11/Apr/2026:12:01:00 +0000] "GET /doesnotexist HTTP/1.1" 404 ...
127.0.0.1 - - [11/Apr/2026:12:01:01 +0000] "GET /another-missing HTTP/1.1" 404 ...

Status code summary:
     10 200
      2 404
```

---

## Task 4 — Monitor Logs in Real Time

Open two terminals.

**Terminal 1** — watch the access log:
```bash
sudo tail -f /var/log/nginx/access.log
```

**Terminal 2** — generate traffic:
```bash
watch -n 1 'curl -s http://localhost > /dev/null'
```

Press `Ctrl+C` in both terminals to stop.

---

## Task 5 — journalctl Deep Dive

```bash
# Logs for the last 30 minutes
sudo journalctl --since "30 minutes ago" --no-pager | head -20

# Logs for just nginx since startup
sudo journalctl -u nginx -b --no-pager | head -30

# Find any kernel errors
sudo journalctl -k -p err --no-pager | head -10

# Export logs to a file for review
sudo journalctl -u nginx --no-pager > ~/nginx-journal.txt
wc -l ~/nginx-journal.txt
```

---

## Task 6 — Write a Simple Log Monitor Script

```bash
cat > ~/check-errors.sh << 'EOF'
#!/bin/bash
# Quick health check: print recent errors from key services

echo "=== nginx errors (last 24h) ==="
sudo journalctl -u nginx -p err --since "24 hours ago" --no-pager 2>/dev/null | tail -5

echo ""
echo "=== Failed SSH logins (last 24h) ==="
sudo grep "Failed\|failure" /var/log/auth.log | grep "$(date '+%b %e')" | wc -l | xargs echo "Count:"

echo ""
echo "=== Disk usage ==="
df -h / | tail -1
EOF

chmod +x ~/check-errors.sh
bash ~/check-errors.sh
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
