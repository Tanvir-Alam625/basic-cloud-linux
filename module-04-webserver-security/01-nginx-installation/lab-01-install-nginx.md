# Lab 01 — Install nginx

## Task 1 — Install and Verify

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl status nginx
curl -s http://localhost | grep -o "Welcome to nginx"
# Expected: Welcome to nginx
```

---

## Task 2 — Explore the Default Configuration

```bash
# Main config
sudo nginx -T 2>/dev/null | head -50   # Show full effective config

# Default virtual host
sudo cat /etc/nginx/sites-available/default

# What's in the default web root?
ls -lh /var/www/html/
```

---

## Task 3 — Customise the Default Page

```bash
# Replace the default nginx page with your own
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head><title>My DevOps Server</title></head>
<body>
  <h1>Welcome to My DevOps Server</h1>
  <p>Nginx is running on Ubuntu 22.04 LTS</p>
  <p>Server IP: REPLACE_WITH_YOUR_IP</p>
</body>
</html>
EOF

# Test it
curl http://localhost
```

---

## Task 4 — Nginx Reload vs Restart

```bash
# Make a harmless config change (add a comment to nginx.conf)
sudo sed -i '1s/^/# DevOps lab config\n/' /etc/nginx/nginx.conf

# Test the config is still valid
sudo nginx -t

# Reload (applies config with zero downtime)
sudo systemctl reload nginx

# Verify it's still running
curl -s -o /dev/null -w "%{http_code}\n" http://localhost
# Expected: 200
```

---

## Task 5 — Check and Review Logs

```bash
# Generate some requests
for i in {1..5}; do curl -s http://localhost > /dev/null; done

# View access log
sudo tail -5 /var/log/nginx/access.log

# View error log
sudo tail -5 /var/log/nginx/error.log
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
