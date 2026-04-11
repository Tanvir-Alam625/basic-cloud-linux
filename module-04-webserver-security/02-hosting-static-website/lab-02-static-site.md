# Lab 02 — Static Website

## Task 1 — Create and Serve Your Site

Follow the lab in [README.md](./README.md) to create `/var/www/mysite/index.html` and the nginx server block.

Verify with:
```bash
curl -s http://localhost | grep "Welcome\|DevOps"
```

---

## Task 2 — Copy the Sample HTML from This Repo

```bash
# Copy the sample index.html from this repo to your web root
sudo cp /path/to/repo/module-04-webserver-security/02-hosting-static-website/html/index.html \
  /var/www/mysite/index.html

# Fix ownership
sudo chown www-data:www-data /var/www/mysite/index.html

# Test
curl http://localhost
```

---

## Task 3 — Add a Second Page and Link to It

```bash
# Create an about page
sudo tee /var/www/mysite/about.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head><title>About</title></head>
<body>
  <h1>About This Server</h1>
  <p>This is the about page.</p>
  <a href="/">Back to Home</a>
</body>
</html>
EOF

sudo chown www-data:www-data /var/www/mysite/about.html

# Test
curl http://localhost/about.html
```

---

## Task 4 — Test 404 Handling

```bash
curl -I http://localhost/nonexistent-page

# Expected:
# HTTP/1.1 404 Not Found
# Server: nginx/...
```

---

## Task 5 — Custom 404 Page

```bash
# Create a custom 404 page
sudo tee /var/www/mysite/404.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<body>
  <h1>404 - Page Not Found</h1>
  <p><a href="/">Go back home</a></p>
</body>
</html>
EOF

sudo chown www-data:www-data /var/www/mysite/404.html

# Add to server block config
sudo sed -i '/try_files/a\        error_page 404 /404.html;' /etc/nginx/sites-available/mysite
sudo nginx -t && sudo systemctl reload nginx

# Test
curl -s http://localhost/missing
```

---

## Task 6 — Verify Security: Hidden Files Blocked

```bash
# Create a test hidden file (simulating a leaked .env)
echo "SECRET=should-not-be-public" | sudo tee /var/www/mysite/.env > /dev/null

# Try to access it — should be forbidden
curl -I http://localhost/.env
# Expected: 403 Forbidden

# The nginx config has: location ~ /\. { deny all; }
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
