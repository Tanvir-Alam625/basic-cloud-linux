# 02 — Hosting a Static Website

## What is a Virtual Host?

A virtual host (server block in nginx) is a configuration that tells nginx how to respond to requests for a specific domain or IP.

By default, nginx has one virtual host serving the default page. You create additional server blocks to:
- Host multiple websites on one server (different domains)
- Serve your own HTML instead of the nginx default page
- Define custom behaviours per domain

---

## The sites-available / sites-enabled Pattern

```bash
# 1. Write your config here (not active yet)
/etc/nginx/sites-available/mysite

# 2. Activate it by creating a symlink
ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite

# 3. Deactivate without deleting
rm /etc/nginx/sites-enabled/mysite

# 4. Always test after changes
sudo nginx -t

# 5. Apply with reload (not restart — no downtime)
sudo systemctl reload nginx
```

---

## Lab — Host a Static Website

### Step 1 — Create Your Web Root Directory

```bash
sudo mkdir -p /var/www/mysite
```

### Step 2 — Create an HTML Page

```bash
sudo tee /var/www/mysite/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My DevOps Site</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
    h1 { color: #333; }
    .info { background: #f4f4f4; padding: 15px; border-radius: 5px; }
  </style>
</head>
<body>
  <h1>Welcome to My DevOps Site</h1>
  <div class="info">
    <p>This site is hosted on an AWS EC2 instance running Ubuntu 22.04 LTS.</p>
    <p>Web server: Nginx</p>
  </div>
</body>
</html>
EOF
```

### Step 3 — Set Correct Permissions

```bash
sudo chown -R www-data:www-data /var/www/mysite/

# Directories need execute permission so nginx can enter them (755)
# Files should NOT be executable — readable only (644)
# chmod -R 755 would wrongly make .html files executable: use find instead
sudo find /var/www/mysite -type d -exec chmod 755 {} +
sudo find /var/www/mysite -type f -exec chmod 644 {} +
```

### Step 4 — Create the Nginx Server Block Config

```bash
sudo tee /etc/nginx/sites-available/mysite > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;

    # Replace with your domain name or use _ to match any
    server_name yourdomain.com www.yourdomain.com;

    # Where your site files live
    root /var/www/mysite;

    # Default file to serve when requesting a directory
    index index.html;

    # Log files for this site
    access_log /var/log/nginx/mysite-access.log;
    error_log  /var/log/nginx/mysite-error.log;

    location / {
        # Try to serve file, then directory, then return 404
        try_files $uri $uri/ =404;
    }
}
EOF
```

> The sample config file with inline comments is also in [configs/mysite.conf](./configs/mysite.conf).

### Step 5 — Disable Default Site and Enable Yours

```bash
# Disable the default nginx site
sudo rm -f /etc/nginx/sites-enabled/default

# Enable your site
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
```

### Step 6 — Test and Reload

```bash
sudo nginx -t
# Expected: test is successful

sudo systemctl reload nginx
```

### Step 7 — Verify

```bash
curl http://localhost
```

You should see your HTML page. Also open `http://YOUR_SERVER_IP` in a browser.

---

## Serving Multiple Sites

You can host multiple sites on one server by creating multiple server blocks with different `server_name` values:

```nginx
# /etc/nginx/sites-available/site1
server {
    server_name site1.com;
    root /var/www/site1;
    ...
}

# /etc/nginx/sites-available/site2
server {
    server_name site2.com;
    root /var/www/site2;
    ...
}
```

nginx routes each request to the correct block based on the `Host` header.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "403 Forbidden" | Check file permissions (`chmod -R 755 /var/www/mysite`) and ownership (`chown -R www-data:www-data`) |
| "404 Not Found" | Check `root` path in config matches where your files actually are |
| Config change not taking effect | Did you run `nginx -t` and `systemctl reload nginx`? |
| Two server blocks with same `server_name` | nginx will use the first one — give each site a unique domain |

---

## Next Step

[03 — Reverse Proxy →](../03-reverse-proxy/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
