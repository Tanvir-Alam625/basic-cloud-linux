# 03 — Logs & Monitoring

## Why Logs Matter

Logs are the first place you look when something goes wrong. A web server returns a 502 error, an application crashes, a user can't log in — the log files tell you exactly what happened and when.

Every serious DevOps skill starts with knowing *where* logs are and *how* to read them efficiently.

---

## Important Log Locations on Ubuntu

| Log File | What It Contains |
|----------|-----------------|
| `/var/log/syslog` | General system messages (the main system log) |
| `/var/log/auth.log` | SSH logins, sudo usage, authentication events |
| `/var/log/nginx/access.log` | Every HTTP request nginx received |
| `/var/log/nginx/error.log` | Nginx errors (config issues, upstream failures) |
| `/var/log/dpkg.log` | Package install/remove history |
| `/var/log/kern.log` | Kernel messages |
| `/var/log/ufw.log` | Firewall allow/deny events (when UFW logging is on) |
| `/var/log/cloud-init.log` | EC2 instance startup/provisioning log |

---

## Core Log Commands

### tail — View the End of a File

```bash
# Last 10 lines (default)
tail /var/log/syslog

# Last 50 lines
tail -n 50 /var/log/syslog

# Follow in real time — stays open, prints new lines as they arrive
tail -f /var/log/nginx/access.log

# Follow multiple files at once
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
```

### grep — Search for Patterns

```bash
# Find all errors in nginx error log
grep "error" /var/log/nginx/error.log

# Case-insensitive search
grep -i "warning" /var/log/syslog

# Show line numbers
grep -n "failed" /var/log/auth.log

# Show context: 2 lines before and after each match
grep -B 2 -A 2 "error" /var/log/nginx/error.log

# Count occurrences
grep -c "GET" /var/log/nginx/access.log

# Invert match — show lines that do NOT contain the pattern
grep -v "127.0.0.1" /var/log/nginx/access.log
```

### journalctl — systemd Journal

```bash
# All logs (very long — use with -n or pipe to less)
sudo journalctl

# Logs for a specific service
sudo journalctl -u nginx

# Last 20 lines
sudo journalctl -u nginx -n 20

# Follow live
sudo journalctl -u nginx -f

# Since last boot
sudo journalctl -b

# Since a time
sudo journalctl --since "2026-04-11 10:00:00"
sudo journalctl --since "1 hour ago"

# Priority: err (only errors and above)
sudo journalctl -p err

# Without pager (useful in scripts)
sudo journalctl -u nginx -n 30 --no-pager
```

---

## Reading nginx Access Logs

nginx access log format:
```
54.123.45.67 - - [11/Apr/2026:12:00:00 +0000] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 ..."
```

| Field | Meaning |
|-------|---------|
| `54.123.45.67` | Client IP |
| `11/Apr/2026:12:00:00 +0000` | Timestamp |
| `GET / HTTP/1.1` | HTTP method, path, protocol |
| `200` | HTTP response code |
| `612` | Response size in bytes |
| `"-"` | Referrer URL (none in this case) |
| `"Mozilla/5.0 ..."` | User agent string |

### Useful Access Log Analysis

```bash
# Count total requests
wc -l /var/log/nginx/access.log

# Top 10 most requested URLs
awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# Top 10 client IPs
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# All 4xx and 5xx errors
grep -E '" [45][0-9]{2} ' /var/log/nginx/access.log

# Requests in the last 5 minutes
awk -v d="$(date -d '5 minutes ago' '+%d/%b/%Y:%H:%M')" '$4 > "["d' /var/log/nginx/access.log
```

---

## Lab — Log Reading Practice

### Step 1 — Explore /var/log

```bash
ls -lh /var/log/
```

Note the sizes and modification times.

### Step 2 — Read the System Log

```bash
# Last 20 lines of syslog
sudo tail -n 20 /var/log/syslog

# Search for your recent SSH logins
sudo grep "Accepted" /var/log/auth.log
```

Expected for auth.log:
```
Apr 11 12:00:00 ip-172-31-xx-xx sshd[1234]: Accepted publickey for ubuntu from 1.2.3.4 port 12345 ssh2
```

### Step 3 — Follow nginx Logs Live

Open two SSH sessions to your server.

**In Session 1** — follow nginx access log:
```bash
sudo tail -f /var/log/nginx/access.log
```

**In Session 2** — generate traffic:
```bash
curl http://localhost/
curl http://localhost/nonexistent
curl http://localhost/
```

**Session 1** should show three new lines arriving in real time.

### Step 4 — Search for Errors

```bash
# View nginx error log
sudo tail -n 20 /var/log/nginx/error.log

# Find only error-level entries
sudo journalctl -u nginx -p err --no-pager

# Count 404 errors today
grep " 404 " /var/log/nginx/access.log | wc -l
```

### Step 5 — Log Rotation

Ubuntu automatically rotates logs to prevent them growing forever:
```bash
ls -lh /var/log/nginx/
# You'll see: access.log, access.log.1, access.log.2.gz ...

# Config for nginx log rotation
cat /etc/logrotate.d/nginx
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Permission denied" reading log | Use `sudo tail /var/log/auth.log` |
| `tail -f` not showing new entries | Nginx may be writing to a rotated file — restart nginx |
| Log file is empty | The service may not have received any requests yet, or log path is configured differently |
| Log file growing too large | Set up logrotate (already configured for nginx by default) |

---

## Next Step

[04 — Firewall (UFW) →](../04-firewall-ufw/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
