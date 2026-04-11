# Mini Project — Solution Walkthrough

**Site:** `aws-basic.ostaddevops.click`  
**Hosted Zone:** `ostaddevops.click` (ID: `Z1019653XLWIJ02C53P5`)  
**Architecture:** EC2 instance → public IP → Route 53 A record → Nginx on the server → Certbot SSL on the server (no Load Balancer)

This guide is entirely manual — every command is typed by you so you understand exactly what each step does.

---

## Phase 1 — Launch and Connect to EC2

**Module reference:** [Module 01](../module-01-aws-ec2-linux/README.md)

### Step 1.1 — Launch the Instance

Go to **EC2 → Instances → Launch instances**.

| Setting | Value |
|---------|-------|
| Name | `aws-basic-server` |
| AMI | Ubuntu Server 22.04 LTS (64-bit x86) |
| Instance type | t2.micro (Free Tier) |
| Key pair | Create new → name it `aws-basic-key` → RSA → .pem → **Download** |
| Security group | Create new → name it `aws-basic-sg` (see rules below) |
| Storage | 8 GB gp3 |

**Security group inbound rules:**

| Type | Port | Source | Why |
|------|------|--------|-----|
| SSH | 22 | My IP | Only you can SSH in |
| HTTP | 80 | 0.0.0.0/0 | Certbot HTTP-01 challenge + plain HTTP |
| HTTPS | 443 | 0.0.0.0/0 | Secure traffic |

> Port 80 **must** be open from anywhere. Certbot verifies domain ownership by making an HTTP request to your server on port 80 before it issues the certificate. If port 80 is blocked the certificate request will fail.

Click **Launch instance**.

---

### Step 1.2 — Allocate and Attach an Elastic IP

A regular EC2 public IP changes every time the instance stops. Certbot embeds your IP in the certificate DNS validation. Use an Elastic IP so the address is permanent.

1. EC2 → **Elastic IPs** → **Allocate Elastic IP address** → Amazon's pool → **Allocate**
2. Select the new EIP → **Actions** → **Associate Elastic IP address**
3. Resource type: Instance → select `aws-basic-server` → **Associate**

Write down the Elastic IP — you will use it in every remaining step:

```
Elastic IP: ___.___.___.___ 
```

---

### Step 1.3 — Connect via SSH

On your local machine (Linux / macOS / WSL / Git Bash):

```bash
# Fix the key file permissions — SSH refuses to use a key that is too open
chmod 400 ~/Downloads/aws-basic-key.pem

# Connect — replace the IP with your actual Elastic IP
ssh -i ~/Downloads/aws-basic-key.pem ubuntu@YOUR_ELASTIC_IP
```

You should see the Ubuntu welcome banner and a prompt like:

```
ubuntu@ip-172-31-xx-xx:~$
```

---

## Phase 2 — Provision the Server

**Module reference:** [Module 01 — apt](../module-01-aws-ec2-linux/06-package-manager-apt/README.md), [Module 02 — UFW](../module-02-linux-administration/04-firewall-ufw/README.md)

Run these commands on the EC2 instance over SSH.

### Step 2.1 — Update the Package Index

```bash
sudo apt update
```

`apt update` refreshes the list of available packages from Ubuntu's repositories. Always do this before installing anything.

### Step 2.2 — Upgrade Installed Packages

```bash
sudo apt upgrade -y
```

Applies all available security and bug-fix updates. The `-y` flag auto-confirms so you don't have to type "Y" for every package.

### Step 2.3 — Install Required Software

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

| Package | Purpose |
|---------|---------|
| `nginx` | Web server that will serve your site |
| `certbot` | Let's Encrypt client that requests and manages SSL certificates |
| `python3-certbot-nginx` | Certbot plugin that can read and modify nginx config automatically |

### Step 2.4 — Start and Enable Nginx

```bash
# Start nginx now
sudo systemctl start nginx

# Make nginx start automatically after every reboot
sudo systemctl enable nginx

# Confirm it is running — look for "active (running)"
sudo systemctl status nginx
```

### Step 2.5 — Configure the OS Firewall (UFW)

AWS Security Groups control traffic at the network level. UFW controls it at the OS level. You need both.

```bash
# Default policies — block all incoming, allow all outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow the three required ports
sudo ufw allow 22/tcp    # SSH — if you skip this you'll lock yourself out
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Enable UFW — this takes effect immediately
sudo ufw --force enable

# Confirm the rules are as expected
sudo ufw status verbose
```

Expected output:
```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
```

### Step 2.6 — Verify Nginx is Reachable

```bash
curl -s http://localhost | grep -o "Welcome to nginx"
```

Expected: `Welcome to nginx`

---

## Phase 3 — Deploy the Website

**Module reference:** [Module 04 — Static Website](../module-04-webserver-security/02-hosting-static-website/README.md)

### Step 3.1 — Create the Web Root Directory

```bash
# Create the directory that will hold your HTML files
sudo mkdir -p /var/www/portfolio

# Give ownership to the ubuntu user (so you can write files) and www-data group (so nginx can read them)
sudo chown -R ubuntu:www-data /var/www/portfolio

# Directories 755 = owner can write, everyone can read and enter
# Files 644 = readable by everyone, writable by owner only
# chmod -R 755 would make HTML files executable (wrong) — use find instead
sudo find /var/www/portfolio -type d -exec chmod 755 {} +
sudo find /var/www/portfolio -type f -exec chmod 644 {} + 2>/dev/null || true
```

### Step 3.2 — Create the HTML Files

You can either clone the repo (if you pushed it to GitHub) or manually create the files. Manual creation below:

```bash
# Create index.html
nano /var/www/portfolio/index.html
```

Paste the content from [html/index.html](../html/index.html) in this repo, then save: `Ctrl+O` → `Enter` → `Ctrl+X`.

```bash
# Create style.css
nano /var/www/portfolio/style.css
```

Paste the content from [html/style.css](../html/style.css) in this repo, then save.

Fix final ownership so nginx can serve both files:

```bash
sudo chown www-data:www-data /var/www/portfolio/index.html
sudo chown www-data:www-data /var/www/portfolio/style.css
ls -lh /var/www/portfolio/
```

Expected:
```
-rw-r--r-- 1 www-data www-data  ... index.html
-rw-r--r-- 1 www-data www-data  ... style.css
```

### Step 3.3 — Create the Nginx Virtual Host Config

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

Paste the following — this is the complete configuration for `aws-basic.ostaddevops.click`:

```nginx
server {
    listen 80;
    listen [::]:80;

    # The exact subdomain this server block responds to
    server_name aws-basic.ostaddevops.click;

    # Where nginx looks for files to serve
    root /var/www/portfolio;

    # File to serve when a directory is requested
    index index.html index.htm;

    # Separate log files for this site (easier debugging)
    access_log /var/log/nginx/portfolio-access.log;
    error_log  /var/log/nginx/portfolio-error.log warn;

    # Try to serve the requested path as a file, then as a directory,
    # and return 404 if neither matches
    location / {
        try_files $uri $uri/ =404;
    }

    # Tell browsers to cache images, fonts, and stylesheets for 30 days.
    # This makes repeat page loads much faster.
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Block access to hidden files like .env or .git
    # Returns 403 Forbidden instead of exposing sensitive files
    location ~ /\. {
        deny all;
    }
}
```

Save: `Ctrl+O` → `Enter` → `Ctrl+X`

### Step 3.4 — Activate the Virtual Host

```bash
# Remove the default nginx page — it would take priority over your site
sudo rm -f /etc/nginx/sites-enabled/default

# Create a symlink to activate your config
# (sites-available = config exists, sites-enabled = config is active)
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/portfolio

# Test the config — nginx checks for syntax errors without restarting
sudo nginx -t
```

Expected:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

```bash
# Reload nginx to apply the new config (no downtime)
sudo systemctl reload nginx

# Verify locally — you should see your HTML, not the default nginx page
curl http://localhost | head -10
```

---

## Phase 4 — Point the Domain to Your Server (Route 53)

**Module reference:** [Module 04 — Route53](../module-04-webserver-security/04-route53-dns/README.md)

Your hosted zone `ostaddevops.click` already exists with ID `Z1019653XLWIJ02C53P5`. You do **not** need to create a new hosted zone or change nameservers. You only need to add one DNS record.

### Step 4.1 — Create an A Record for the Subdomain

**Console:**
1. Go to **Route 53 → Hosted zones → ostaddevops.click**
2. Click **Create record**
3. Fill in the form:

| Field | Value | Explanation |
|-------|-------|-------------|
| Record name | `aws-basic` | This becomes `aws-basic.ostaddevops.click` — leave the zone name (`ostaddevops.click`) alone, just type the prefix |
| Record type | **A** | A record maps a name to an IPv4 address |
| Value | `YOUR_ELASTIC_IP` | The Elastic IP you noted in Step 1.2 — paste the actual IP here |
| TTL | `300` | How long DNS resolvers cache this record (seconds). 300 = 5 minutes, good for initial setup |
| Routing policy | Simple routing | Direct traffic straight to your server, no health checks needed |

4. Click **Create records**

**CLI:**
```bash
ELASTIC_IP="YOUR_ELASTIC_IP"   # the Elastic IP from Step 1.2

aws route53 change-resource-record-sets \
  --hosted-zone-id Z1019653XLWIJ02C53P5 \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "aws-basic.ostaddevops.click",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "'"$ELASTIC_IP"'"}]
      }
    }]
  }'
```

> **Why A record and not CNAME?** A CNAME maps a name to another name. An A record maps a name directly to an IP address. Since you have a real static IP (Elastic IP), use an A record — it's one less lookup and works correctly at the zone apex.

### Step 4.2 — Wait for DNS Propagation

DNS changes don't take effect instantly. With TTL=300, propagation can take up to 5 minutes for new records.

Check from inside the EC2 instance:

```bash
# Install dig if not present
sudo apt install -y dnsutils

# Query AWS's own DNS resolver for your record
dig aws-basic.ostaddevops.click A +short
```

Expected output — your Elastic IP:
```
X.X.X.X
```

If you see nothing or a different IP, wait 2–3 minutes and try again. Also check from your local machine:

```bash
# From your local terminal (not the EC2 instance)
nslookup aws-basic.ostaddevops.click
```

### Step 4.3 — Verify HTTP Reaches Your Site

Once DNS resolves, test over HTTP before running Certbot:

```bash
# From the EC2 instance
curl -I http://aws-basic.ostaddevops.click
```

Expected:
```
HTTP/1.1 200 OK
Server: nginx/...
```

> **Do not run Certbot until this step succeeds.** Certbot proves domain ownership by making an HTTP request to `http://aws-basic.ostaddevops.click/.well-known/acme-challenge/...`. If DNS has not propagated yet, or port 80 is blocked, the challenge fails and you will not get a certificate.

---

## Phase 5 — SSL Certificate with Certbot

**Module reference:** [Module 04 — SSL](../module-04-webserver-security/06-ssl-certbot/README.md)

Certbot will:
1. Contact Let's Encrypt and request a certificate for `aws-basic.ostaddevops.click`
2. Place a temporary challenge file in your web root
3. Let's Encrypt makes an HTTP request to verify you control the domain
4. Issue the certificate (valid 90 days, stored in `/etc/letsencrypt/`)
5. Automatically modify `/etc/nginx/sites-available/portfolio` to add the HTTPS block

### Step 5.1 — Run Certbot

```bash
sudo certbot --nginx -d aws-basic.ostaddevops.click
```

Walk through the prompts:

```
Enter email address (for renewal notices and emergency contact):
→ type your email address

Please read the Terms of Service at https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf
→ Y

Would you like to share your email with the Electronic Frontier Foundation?
→ N (your choice)

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/aws-basic.ostaddevops.click/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/aws-basic.ostaddevops.click/privkey.pem

Deploying certificate to VirtualHost /etc/nginx/sites-available/portfolio
→ Certbot edits your nginx config automatically

Please choose whether to redirect HTTP traffic to HTTPS:
1: No redirect
2: Redirect (recommended)
→ 2
```

Option 2 makes Certbot add a redirect rule to your nginx config so plain HTTP automatically goes to HTTPS.

### Step 5.2 — Inspect What Certbot Changed

Certbot modified your nginx config. Look at what it added:

```bash
cat /etc/nginx/sites-available/portfolio
```

You will see your original `server` block (now with `listen 443 ssl`) and a new redirect block at the top:

```nginx
server {
    if ($host = aws-basic.ostaddevops.click) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name aws-basic.ostaddevops.click;
    return 404;
}
```

This is how HTTP → HTTPS redirect works: any HTTP request returns `301 Moved Permanently` pointing to the HTTPS version.

### Step 5.3 — Verify HTTPS is Working

```bash
# HTTPS should return 200
curl -I https://aws-basic.ostaddevops.click
```

Expected:
```
HTTP/2 200
server: nginx/...
```

```bash
# HTTP should automatically redirect to HTTPS
curl -I http://aws-basic.ostaddevops.click
```

Expected:
```
HTTP/1.1 301 Moved Permanently
Location: https://aws-basic.ostaddevops.click/
```

```bash
# Inspect the certificate — confirm the domain and expiry date
sudo certbot certificates
```

Expected:
```
Found the following certs:
  Certificate Name: aws-basic.ostaddevops.click
    Domains: aws-basic.ostaddevops.click
    Expiry Date: YYYY-MM-DD (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/aws-basic.ostaddevops.click/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/aws-basic.ostaddevops.click/privkey.pem
```

Open your browser and go to `https://aws-basic.ostaddevops.click` — you should see the padlock and your portfolio page.

---

## Phase 6 — Ongoing Maintenance

### Step 6.1 — Test Automatic Certificate Renewal

Certbot installs a systemd timer that runs renewal checks twice a day. Test it with a dry run (no actual renewal happens):

```bash
sudo certbot renew --dry-run
```

Expected:
```
Simulating renewal of an existing certificate for aws-basic.ostaddevops.click
...
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/aws-basic.ostaddevops.click/fullchain.pem (success)
```

### Step 6.2 — Add a Cron Job as a Backup Renewal

The systemd timer is the primary renewal mechanism. Add a cron job as a belt-and-suspenders backup.

> **Important:** `certbot renew` requires root to read certificates and reload nginx. Use `sudo crontab -e` to install the job in root's crontab. A user-level `crontab -e` will not work.

```bash
sudo crontab -e
```

Add these two lines at the bottom:

```cron
# Attempt SSL certificate renewal at midnight and noon every day.
# Certbot only renews if the cert is within 30 days of expiry — safe to run often.
0 0,12 * * *  /usr/bin/certbot renew --quiet >> /var/log/certbot-renew.log 2>&1
```

Log disk usage in your home directory (ubuntu user has no write permission to /var/log):

```bash
crontab -e
```

Add:
```cron
# Log disk usage every morning so you notice before the disk fills up
0 8 * * *     df -h >> ~/logs/disk-usage.log 2>&1
```

> The certbot cron goes in root's crontab (`sudo crontab -e`). The disk-usage cron goes in the ubuntu user's crontab — it writes to `~/logs/` which the ubuntu user owns.

### Step 6.3 — Useful Day-to-Day Commands

```bash
# View live nginx access logs (who is visiting)
sudo tail -f /var/log/nginx/portfolio-access.log

# View nginx error logs (debugging)
sudo tail -f /var/log/nginx/portfolio-error.log

# Check disk space
df -h

# Check memory
free -h

# Check what is listening on ports 80 and 443
sudo ss -tlnp | grep -E ':80|:443'

# Reload nginx after editing the config (no downtime)
sudo nginx -t && sudo systemctl reload nginx
```

---

## Final Verification Checklist

Run all of these after completing all phases. Everything should pass.

```bash
# 1. DNS resolves to your Elastic IP
dig aws-basic.ostaddevops.click A +short
# Expected: your Elastic IP

# 2. HTTP redirects to HTTPS
curl -I http://aws-basic.ostaddevops.click
# Expected: HTTP/1.1 301  Location: https://aws-basic.ostaddevops.click/

# 3. HTTPS returns 200
curl -I https://aws-basic.ostaddevops.click
# Expected: HTTP/2 200

# 4. Nginx config has no syntax errors
sudo nginx -t
# Expected: syntax ok + test successful

# 5. Certificate is valid
sudo certbot certificates
# Expected: VALID, domain = aws-basic.ostaddevops.click

# 6. Certbot auto-renewal works
sudo certbot renew --dry-run
# Expected: all simulated renewals succeeded

# 7. UFW has the correct rules
sudo ufw status verbose
# Expected: 22, 80, 443 ALLOW IN

# 8. Nginx starts automatically at boot
sudo systemctl is-enabled nginx
# Expected: enabled

# 9. The site loads from a browser
# Open: https://aws-basic.ostaddevops.click
# Expected: padlock icon + your portfolio page
```

# 9. Auto-renewal works
sudo certbot renew --dry-run
```

---

## Congratulations

You've deployed a production-ready HTTPS website on AWS with:

| Component | Technology |
|-----------|-----------|
| Cloud | AWS EC2 (Ubuntu 22.04) |
| Firewall | UFW + Security Groups |
| Web Server | Nginx |
| DNS | Route53 |
| SSL | Let's Encrypt / Certbot |
| Automation | Bash scripts + Cron |

This is the same stack that powers millions of production websites.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
