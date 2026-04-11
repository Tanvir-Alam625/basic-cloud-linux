# Lab 06 — SSL with Certbot

## Task 1 — Pre-flight Check

Before running certbot, verify everything is ready:

```bash
# 1. Domain resolves to this server
curl -4 https://checkip.amazonaws.com     # Your server's public IP
dig yourdomain.com A +short               # Should match

# 2. Port 80 is accessible
curl -I http://yourdomain.com
# Expected: HTTP/1.1 200 OK (must work before certbot can verify the domain)

# 3. Port 443 is open in UFW
sudo ufw status | grep 443

# 4. nginx is running
sudo systemctl is-active nginx
```

**Verify port 443 is open in your AWS Security Group:**

_Console:_ EC2 → **Instances** → click your instance → **Security** tab → click the Security Group name → **Inbound rules** — confirm a rule for port 443 (HTTPS) from `0.0.0.0/0` exists.

_CLI:_
```bash
# Get the Security Group ID attached to your instance
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

# View inbound rules for that Security Group
aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`443\`]" \
  --output table

# If port 443 is missing, add it:
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

---

## Task 2 — Install Certbot

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
certbot --version
```

---

## Task 3 — Obtain the Certificate

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow the prompts. When done, verify:

```bash
# Check certificate status
sudo certbot certificates

# Test HTTPS
curl -I https://yourdomain.com
# Expected: HTTP/2 200
```

---

## Task 4 — Verify Auto-Renewal

```bash
# Dry run — tests renewal without actually renewing
sudo certbot renew --dry-run
# Expected: "All simulated renewals succeeded"

# Check the timer is active
sudo systemctl status certbot.timer

# Find the actual renewal check time
sudo systemctl list-timers | grep certbot
```

---

## Task 5 — Inspect the Certificate

```bash
# See expiry and domain info
sudo certbot certificates

# Full certificate details
sudo openssl x509 \
  -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem \
  -noout \
  -subject -dates -issuer

# Expected:
# subject=CN=yourdomain.com
# notBefore=Apr 11 00:00:00 2026 GMT
# notAfter=Jul 10 00:00:00 2026 GMT
# issuer=C=US, O=Let's Encrypt, CN=R3
```

---

## Task 6 — Force HTTPS and Test Redirect

```bash
# Test that HTTP redirects to HTTPS
curl -I http://yourdomain.com
# Expected:
# HTTP/1.1 301 Moved Permanently
# Location: https://yourdomain.com/

# Follow the redirect
curl -L http://yourdomain.com -o /dev/null -w "%{http_code}\n"
# Expected: 200 (final status after following redirect)
```

---

## Task 7 — Set Up Cron for SSL Renewal (Belt and Suspenders)

Certbot's systemd timer handles renewal automatically. You can also add a cron job as a backup.

> **Important:** `certbot renew` requires root to read certificate files and reload nginx.
> Use `sudo crontab -e` to install the job in root's crontab, not a regular user's.

```bash
sudo crontab -e
```

Add:
```
# SSL renewal check — twice daily (certbot only renews if expiry < 30 days)
0 0,12 * * *  /usr/bin/certbot renew --quiet >> /var/log/certbot-renew.log 2>&1
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
