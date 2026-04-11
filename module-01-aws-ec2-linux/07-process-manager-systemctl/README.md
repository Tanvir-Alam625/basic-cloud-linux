# 07 — Process Manager (systemctl)

## What is systemctl?

`systemctl` is the command used to manage **systemd services** — background processes that run continuously on your Linux server.

A **service** (also called a daemon) is a program that starts automatically at boot and runs in the background. Examples:
- `nginx` — web server (listens for HTTP requests)
- `ssh` — allows SSH connections
- `cron` — runs scheduled tasks

`systemctl` lets you start, stop, restart, enable, disable, and inspect these services.

---

## Core Commands

```bash
# Check the status of a service
sudo systemctl status nginx

# Start a service
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart a service (stop then start)
sudo systemctl restart nginx

# Reload a service (applies config changes without full restart — faster)
sudo systemctl reload nginx

# Enable a service to start automatically at boot
sudo systemctl enable nginx

# Disable a service from starting at boot
sudo systemctl disable nginx

# Enable AND start in one command
sudo systemctl enable --now nginx

# Check if a service is enabled at boot
sudo systemctl is-enabled nginx

# Check if a service is currently running
sudo systemctl is-active nginx
```

---

## Understanding systemctl status Output

```bash
sudo systemctl status nginx
```

```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2026-04-11 12:00:00 UTC; 5min ago
       Docs: man:nginx(8)
   Main PID: 1234 (nginx)
      Tasks: 2 (limit: 1141)
     Memory: 4.2M
        CPU: 12ms
     CGroup: /system.slice/nginx.service
             ├─1234 "nginx: master process /usr/sbin/nginx -g daemon off;"
             └─1235 "nginx: worker process"

Apr 11 12:00:00 ip-172-31-xx-xx systemd[1]: Starting A high performance...
Apr 11 12:00:00 ip-172-31-xx-xx nginx[1234]: nginx: configuration file...OK
Apr 11 12:00:00 ip-172-31-xx-xx systemd[1]: Started A high performance...
```

What to look for:
- **Loaded** — is the service config file found? Is it enabled at boot?
- **Active: active (running)** — service is up ✓
- **Active: inactive (dead)** — service is stopped
- **Active: failed** — service crashed — check the log lines at the bottom
- **Main PID** — the process ID of the service
- **Log lines** at the bottom — most recent output from the service

---

## Listing All Services

```bash
# Show all loaded and active services
systemctl list-units --type=service

# Show all services and their state
systemctl list-units --type=service --all

# Show services that failed
systemctl list-units --type=service --state=failed
```

---

## Reading Service Logs with journalctl

```bash
# View logs for a service
sudo journalctl -u nginx

# Live-follow logs (like tail -f)
sudo journalctl -u nginx -f

# Last 50 lines of logs
sudo journalctl -u nginx -n 50

# Logs since last boot
sudo journalctl -u nginx -b

# Logs since a specific time
sudo journalctl -u nginx --since "2026-04-11 12:00:00"
```

---

## Lab — Manage nginx with systemctl

### Step 1 — Install nginx

```bash
sudo apt update
sudo apt install -y nginx
```

### Step 2 — Check Its Status

```bash
sudo systemctl status nginx
```

After installing, nginx is automatically started. You should see:
```
Active: active (running)
```

### Step 3 — Test in Your Browser

Open `http://YOUR_SERVER_IP` in a browser. You should see the nginx welcome page.

Or test from the command line:
```bash
curl http://localhost
```

Expected: HTML output with "Welcome to nginx!"

### Step 4 — Stop and Start

```bash
# Stop nginx
sudo systemctl stop nginx

# Verify it's stopped
sudo systemctl status nginx
# Active: inactive (dead)

# Test — should now fail
curl http://localhost
# curl: (7) Failed to connect to localhost port 80: Connection refused

# Start it again
sudo systemctl start nginx
sudo systemctl status nginx
# Active: active (running)
```

### Step 5 — Ensure nginx Starts at Boot

```bash
# Check current boot behaviour
sudo systemctl is-enabled nginx
# Expected: enabled

# If it shows "disabled", enable it:
sudo systemctl enable nginx
```

### Step 6 — Reload After Config Change

When you change nginx's configuration file, use `reload` instead of `restart` to apply changes with zero downtime:

```bash
# Make a trivial config change
sudo nano /etc/nginx/nginx.conf
# (don't actually change anything — just save and exit)

# Test the config before applying
sudo nginx -t
# Expected: nginx: configuration file /etc/nginx/nginx.conf test is successful

# Apply the change with reload (no downtime)
sudo systemctl reload nginx
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `systemctl start nginx` fails silently | Run `systemctl status nginx` — the log lines at the bottom show the error |
| Service starts but then stops immediately | Check `journalctl -u nginx -n 20` for the crash reason |
| Forgot to enable — service doesn't survive reboot | Run `sudo systemctl enable nginx` |
| `reload` fails with error | Run `sudo nginx -t` first — there's a config syntax error |
| "Unit not found" | The package is not installed, or the service name is wrong |

---

## Next Step

Proceed to [Module 02 — Linux Administration →](../../module-02-linux-administration/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
