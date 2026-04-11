# 01 — Nginx Installation

## What is Nginx?

Nginx (pronounced "engine-x") is a high-performance web server and reverse proxy. It's one of the most widely used web servers in the world, running under millions of production websites.

Nginx can:
- Serve static files (HTML, CSS, images)
- Act as a reverse proxy (forward requests to an app server like Node.js)
- Handle SSL/TLS termination
- Load balance across multiple servers
- Cache responses

---

## Nginx Architecture

When a request comes in:

```
Browser → Nginx (port 80/443) → response
                   ↓
      reads from /var/www/html/   ← static files
              OR
      forwards to localhost:3000  ← app server (reverse proxy)
```

Nginx uses an event-driven architecture — one worker process can handle thousands of simultaneous connections, which is why it's so efficient.

---

## Key Files and Directories

| Path | Purpose |
|------|---------|
| `/etc/nginx/nginx.conf` | Main configuration file |
| `/etc/nginx/sites-available/` | Config files for each website (inactive) |
| `/etc/nginx/sites-enabled/` | Symlinks to active site configs |
| `/var/www/html/` | Default web root — where you put HTML files |
| `/var/log/nginx/access.log` | Every request logged here |
| `/var/log/nginx/error.log` | Errors logged here |

`sites-available/` and `sites-enabled/` work together:
- Write config in `sites-available/mysite`
- Activate it: `ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/`
- Deactivate: `rm /etc/nginx/sites-enabled/mysite`

---

## Lab — Install and Verify Nginx

### Step 1 — Install

```bash
sudo apt update
sudo apt install -y nginx
```

### Step 2 — Check Status

```bash
sudo systemctl status nginx
```

Expected:
```
● nginx.service - A high performance web server and a reverse proxy server
     Active: active (running) ...
```

### Step 3 — Verify It's Listening on Port 80

```bash
ss -tlnp | grep :80
```

Expected:
```
LISTEN  0  511  0.0.0.0:80  0.0.0.0:*  users:(("nginx",pid=xxxx))
```

### Step 4 — Test the Default Page

```bash
curl http://localhost
```

Expected: HTML output containing "Welcome to nginx!"

Or open `http://YOUR_SERVER_IP` in a browser. You'll see the nginx welcome page.

### Step 5 — Enable at Boot

```bash
sudo systemctl enable nginx
sudo systemctl is-enabled nginx
# Expected: enabled
```

### Step 6 — Allow Through UFW

If UFW is enabled (from Module 02):

```bash
sudo ufw allow 'Nginx Full'
sudo ufw status
```

Expected:
```
Nginx Full                 ALLOW       Anywhere
```

---

## Nginx File Structure Walk Through

```bash
# View the main config
sudo cat /etc/nginx/nginx.conf

# View the default site config
sudo cat /etc/nginx/sites-available/default

# List what's enabled
ls -la /etc/nginx/sites-enabled/
```

The default config in `sites-available/default` serves files from `/var/www/html/`.

### Understanding a Basic Server Block

```nginx
server {
    listen 80;                          # Listen on port 80
    listen [::]:80;                     # Listen on IPv6 port 80
    
    server_name _;                      # Match any hostname
    
    root /var/www/html;                 # Serve files from this directory
    index index.html index.htm;         # Default files to serve
    
    location / {
        try_files $uri $uri/ =404;      # Return 404 if file not found
    }
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Address already in use" when starting nginx | Another process is using port 80: `sudo lsof -i :80` then kill it |
| "403 Forbidden" when visiting the site | Web files have wrong permissions or wrong owner. Run `sudo chown -R www-data:www-data /var/www/html` |
| Config change has no effect | Did you run `sudo nginx -t` (test) then `sudo systemctl reload nginx` (apply)? |
| Nginx not in PATH | Use full path: `/usr/sbin/nginx` |

---

## Next Step

[02 — Hosting a Static Website →](../02-hosting-static-website/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
