# Lab 05 — Domain Mapping

## Task 1 — Verify DNS Before Configuring nginx

```bash
# Check domain resolves to your server IP
dig yourdomain.com A +short
# Expected: your EC2 public IP

# Check www too
dig www.yourdomain.com A +short

# If both return your IP, DNS is ready
```

---

## Task 2 — Update nginx server_name and Test

```bash
# Edit the site config
sudo nano /etc/nginx/sites-available/mysite
# Change server_name to your real domain

# Test and reload
sudo nginx -t && sudo systemctl reload nginx

# Test with the domain via curl
curl -v http://yourdomain.com 2>&1 | head -30
```

---

## Task 3 — www Redirect

Add a separate server block that redirects `www` to the root domain:

```bash
sudo tee /etc/nginx/sites-available/www-redirect > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name www.yourdomain.com;
    return 301 http://yourdomain.com$request_uri;
}
EOF

sudo ln -s /etc/nginx/sites-available/www-redirect /etc/nginx/sites-enabled/www-redirect
sudo nginx -t && sudo systemctl reload nginx

# Test the redirect
curl -I http://www.yourdomain.com
# Expected: HTTP/1.1 301 Moved Permanently
# Location: http://yourdomain.com/
```

---

## Task 4 — Test Multiple Domain Configs

```bash
# Check your nginx is handling the right domains
sudo nginx -T 2>/dev/null | grep -A 3 "server_name"

# Make sure you can reach specific pages
curl http://yourdomain.com/about.html
curl http://yourdomain.com/nonexistent  # Should 404

# Check response headers
curl -I http://yourdomain.com
# Look for: Server: nginx/...
```

---

## Task 5 — Log Analysis

After accessing your site through the domain:

```bash
# See requests with the actual Host header
sudo tail -10 /var/log/nginx/mysite-access.log

# Check the request hit the right server block
sudo grep "yourdomain.com" /var/log/nginx/mysite-access.log | head -3
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
