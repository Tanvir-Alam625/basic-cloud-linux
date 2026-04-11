# 03 — Reverse Proxy

## What is a Reverse Proxy?

A reverse proxy sits in front of an application server and forwards incoming requests to it. To the outside world, everything goes through nginx on port 80/443. nginx then proxies the request to whatever is running internally (e.g. a Node.js app on port 3000).

```
Internet
    │
    ▼
nginx (port 80/443)  ←── the only port exposed publicly
    │
    ▼ proxy_pass
App Server (port 3000)  ←── only accessible internally
```

**Why use a reverse proxy?**
- One nginx handles SSL termination for all apps
- Apps don't need to be exposed publicly
- Nginx can add security headers, rate limiting, caching
- Multiple apps can share the same public IP

---

## Core Nginx Proxy Directives

```nginx
location / {
    proxy_pass http://localhost:3000;           # Forward to app on port 3000

    proxy_http_version 1.1;                     # Use HTTP/1.1 (needed for WebSockets)
    proxy_set_header Upgrade $http_upgrade;     # WebSocket support
    proxy_set_header Connection 'upgrade';      # WebSocket support

    proxy_set_header Host $host;                # Pass the original Host header
    proxy_set_header X-Real-IP $remote_addr;   # Pass the real client IP
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  # IP chain
    proxy_set_header X-Forwarded-Proto $scheme; # Pass http or https

    proxy_cache_bypass $http_upgrade;           # Don't cache WebSocket upgrades
}
```

---

## Lab — Set Up a Reverse Proxy

### Step 1 — Start a Simple Backend Server

We'll use Python's built-in HTTP server to simulate an app:

```bash
# In the background, start a simple HTTP server on port 3000
mkdir -p /tmp/testapp
echo "<h1>Hello from the App Server on port 3000</h1>" > /tmp/testapp/index.html
cd /tmp/testapp
python3 -m http.server 3000 &
APP_PID=$!
echo "App server started with PID $APP_PID"
```

Verify it's running:
```bash
curl http://localhost:3000
# Expected: Hello from the App Server on port 3000
```

### Step 2 — Create the Reverse Proxy Config

```bash
sudo tee /etc/nginx/sites-available/myapp > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name app.yourdomain.com;   # Or use _ to match any

    # Proxy all requests to the app server
    location / {
        proxy_pass http://localhost:3000;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
```

The complete config with all comments is in [configs/reverse-proxy.conf](./configs/reverse-proxy.conf).

### Step 3 — Enable and Test

```bash
# Disable default if still enabled
sudo rm -f /etc/nginx/sites-enabled/default

# Enable the reverse proxy config
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp

# Test
sudo nginx -t

# Apply
sudo systemctl reload nginx

# Test through nginx (port 80 → app on 3000)
curl http://localhost
```

Expected: `<h1>Hello from the App Server on port 3000</h1>`

One request through nginx, served by the Python process on port 3000.

### Step 4 — Verify Headers

```bash
curl -I http://localhost
```

You'll see the response headers. Your app's response is delivered through nginx.

### Step 5 — Clean Up the Test App

```bash
kill $APP_PID 2>/dev/null
rm -rf /tmp/testapp
```

---

## Proxying a Specific URL Path

You don't have to proxy everything. You can proxy just one path:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # Serve static files normally
    root /var/www/mysite;
    location / {
        try_files $uri $uri/ =404;
    }

    # Proxy just the /api path to a backend service
    location /api/ {
        proxy_pass http://localhost:4000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "502 Bad Gateway" | The app server on the proxied port is not running |
| "504 Gateway Timeout" | App is running but not responding fast enough |
| App gets wrong client IP | Add `proxy_set_header X-Real-IP $remote_addr;` |
| Trailing slash issues | `proxy_pass http://localhost:3000` vs `http://localhost:3000/` — the trailing slash changes URL rewriting behaviour |

---

## Next Step

[04 — Route53 & DNS →](../04-route53-dns/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
