# 06 — SSL with Certbot (Let's Encrypt)

## Why HTTPS?

HTTP sends data in plain text — anyone who intercepts the traffic (on public Wi-Fi, for example) can read it. HTTPS encrypts the connection using TLS (Transport Layer Security).

Modern browsers show a warning for non-HTTPS sites. Google also ranks HTTPS sites higher in search results. There is no reason not to use HTTPS — and with Let's Encrypt, it's completely free.

---

## How Certbot Works

**Let's Encrypt** is a free Certificate Authority (CA) that issues SSL certificates.

**Certbot** is a tool that:
1. Proves to Let's Encrypt that you control the domain (by placing a challenge file on your web server)
2. Downloads the certificate
3. Configures nginx automatically to use it
4. Sets up auto-renewal

Certificates are valid for **90 days** and are renewed automatically by a cron job that certbot sets up.

---

## Prerequisites

- A domain name pointing to your server (`yourdomain.com` → your EC2 IP)
- Port 80 and 443 open in both Security Group and UFW
- Nginx installed and serving your domain on port 80

> The DNS A record MUST resolve to your server before running certbot. Let's Encrypt verifies domain ownership over HTTP.

---

## Lab — Install and Run Certbot

### Step 1 — Install Certbot

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### Step 2 — Obtain and Install the Certificate

Replace `yourdomain.com` with your actual domain:

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

You'll be prompted for:
- Email address (for renewal reminders and urgent notices)
- Agreement to Terms of Service
- Whether to share your email with EFF

Certbot will:
1. Verify you own the domain (HTTP challenge on port 80)
2. Download the certificate to `/etc/letsencrypt/live/yourdomain.com/`
3. Automatically modify your nginx config to use HTTPS
4. Redirect HTTP → HTTPS automatically

Expected final output:
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/yourdomain.com/fullchain.pem
Key is saved at: /etc/letsencrypt/live/yourdomain.com/privkey.pem
This certificate expires on 2026-07-10.

Deploying certificate to /etc/nginx/sites-enabled/mysite
...
Congratulations! You have successfully enabled HTTPS on https://yourdomain.com
```

### Step 3 — Verify HTTPS is Working

```bash
# Test HTTPS response
curl -I https://yourdomain.com
```

Expected:
```
HTTP/2 200
server: nginx/...
content-type: text/html
...
```

Or open `https://yourdomain.com` in a browser — the padlock icon should appear.

### Step 4 — View What Certbot Added to Your nginx Config

```bash
sudo cat /etc/nginx/sites-available/mysite
```

Certbot added:
- `listen 443 ssl;` block
- `ssl_certificate` and `ssl_certificate_key` paths
- HTTP → HTTPS redirect
- `managed by Certbot` comments

### Step 5 — Test Auto-Renewal

```bash
# Simulate a renewal without actually renewing
sudo certbot renew --dry-run
```

Expected:
```
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/yourdomain.com/fullchain.pem (success)
```

### Step 6 — View the Renewal Schedule

Certbot installs a systemd timer for automatic renewal:

```bash
sudo systemctl status certbot.timer
# Active: active (waiting) ...

sudo systemctl list-timers | grep certbot
# certbot.timer certbot.service  ...
```

Certbot checks twice daily and renews if the cert expires in less than 30 days.

---

## Certificate Information

```bash
# View certificate details
sudo certbot certificates

# View the actual certificate content
sudo openssl x509 -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -text -noout | head -20

# Check expiry date
sudo openssl x509 -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -noout -dates
```

---

## What the Final nginx Config Looks Like

After certbot runs, your nginx config will look like:

```nginx
server {
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/mysite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Added by Certbot
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    # Redirect HTTP to HTTPS — added by Certbot
    if ($host = www.yourdomain.com) {
        return 301 https://$host$request_uri;
    }
    if ($host = yourdomain.com) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 404;
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Domain not resolved" error from certbot | DNS hasn't propagated yet. Wait and retry. |
| "Port 80 is not open" | Check UFW: `sudo ufw allow 80` and Security Group allows port 80 |
| Certificate obtained but nginx still shows HTTP | Run `sudo systemctl reload nginx` |
| Renewal fails | Check `sudo certbot renew --dry-run` — usually a network or permission issue |
| "Too many requests" error from Let's Encrypt | Rate limited — wait an hour. Don't run certbot repeatedly in testing. |

---

## Next Step

Proceed to [Module 05 — Mini Project →](../../module-05-mini-project/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
