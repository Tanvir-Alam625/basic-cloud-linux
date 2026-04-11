# Lab 06 — systemctl

## Task 1 — Explore Running Services

```bash
# List all active services
systemctl list-units --type=service --state=active

# How many are running?
systemctl list-units --type=service --state=active | wc -l

# Find the SSH service
systemctl status ssh
```

---

## Task 2 — nginx Service Lifecycle

```bash
# Install nginx if not already installed
sudo apt update && sudo apt install -y nginx

# Check initial status
sudo systemctl status nginx

# Stop it
sudo systemctl stop nginx
sudo systemctl is-active nginx
# Expected: inactive

# Start it
sudo systemctl start nginx
sudo systemctl is-active nginx
# Expected: active

# Restart it (stop + start in one command)
sudo systemctl restart nginx

# Verify it came back
curl -s http://localhost | grep -o "Welcome to nginx"
# Expected: Welcome to nginx
```

---

## Task 3 — Enable/Disable at Boot

```bash
# Check if enabled
sudo systemctl is-enabled nginx
# Expected: enabled

# Disable it
sudo systemctl disable nginx
sudo systemctl is-enabled nginx
# Expected: disabled

# Re-enable it
sudo systemctl enable nginx
sudo systemctl is-enabled nginx
# Expected: enabled
```

---

## Task 4 — Read Service Logs

```bash
# Show the last 20 log entries for nginx
sudo journalctl -u nginx -n 20

# Trigger an error: point nginx at a bad config
echo "invalid config here" | sudo tee /etc/nginx/conf.d/bad.conf

# Test config (should fail)
sudo nginx -t
# Expected: nginx: [emerg] ... configuration file /etc/nginx/nginx.conf test failed

# Try to reload (should fail)
sudo systemctl reload nginx

# Read the error in the journal
sudo journalctl -u nginx -n 10
# You'll see the error about the bad config

# Fix the mistake
sudo rm /etc/nginx/conf.d/bad.conf
sudo nginx -t
# Expected: test is successful

sudo systemctl reload nginx
```

---

## Task 5 — Check Boot-Time Service Status

```bash
# See which services run at boot (enabled)
systemctl list-unit-files --type=service --state=enabled | head -20

# See which services failed on last boot
systemctl list-units --type=service --state=failed
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
