# Lab 03 — Reverse Proxy

## Task 1 — Full End-to-End Reverse Proxy

```bash
# Start a Python app server on port 3000
mkdir -p /tmp/testapp
cat > /tmp/testapp/index.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
  <h1>Response from App Server (port 3000)</h1>
  <p>This content was served by Python's http.server.</p>
  <p>Nginx forwarded your request here via proxy_pass.</p>
</body>
</html>
EOF

cd /tmp/testapp
python3 -m http.server 3000 &
APP_PID=$!

# Confirm app is directly accessible
curl http://localhost:3000

# Set up the nginx reverse proxy (from the README lab)
sudo tee /etc/nginx/sites-available/myapp > /dev/null << 'NGINX'
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

sudo rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/mysite
sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
sudo nginx -t && sudo systemctl reload nginx

# Test via nginx (port 80) — nginx proxies to port 3000
curl http://localhost
```

---

## Task 2 — Verify Headers Are Passed

```bash
# Your app can use this to see the headers nginx passes
python3 - << 'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        response = "\n".join(f"{k}: {v}" for k, v in self.headers.items())
        self.wfile.write(response.encode())
    def log_message(self, *args):
        pass

# Stop the previous server first
PY

kill $APP_PID 2>/dev/null; sleep 1

python3 -c "
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        response = '\n'.join(f'{k}: {v}' for k, v in self.headers.items())
        self.wfile.write(response.encode())
    def log_message(self, *a): pass

HTTPServer(('', 3000), Handler).serve_forever()
" &
APP_PID=$!
sleep 1

# Make a request via nginx
curl http://localhost
# Expected: You'll see X-Real-IP, X-Forwarded-For, Host, etc. passed by nginx
```

---

## Task 3 — 502 Simulation

```bash
# Kill the app server
kill $APP_PID 2>/dev/null

# Now access nginx — nginx tries to forward but the app is gone
curl -I http://localhost
# Expected:
# HTTP/1.1 502 Bad Gateway

# Read the error log
sudo tail -5 /var/log/nginx/error.log
# Expected: [error] ... connect() failed ... Connection refused
```

---

## Task 4 — Clean Up

```bash
# Remove the test configs and restore default
sudo rm -f /etc/nginx/sites-enabled/myapp
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 2>/dev/null || true
sudo nginx -t && sudo systemctl reload nginx
rm -rf /tmp/testapp
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
