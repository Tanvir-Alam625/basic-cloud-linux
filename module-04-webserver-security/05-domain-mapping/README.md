# 05 — Domain Mapping

## What is Domain Mapping?

Domain mapping connects your domain name to your server in nginx. Once DNS resolves `yourdomain.com` to your server's IP, nginx must be configured to:
1. Recognise requests for `yourdomain.com`
2. Serve the right content for that domain

This is done with the `server_name` directive in your nginx server block.

---

## Prerequisites for This Topic

- A domain name set up in Route53 (topic 04)
- DNS propagated — `dig yourdomain.com A` returns your server's IP
- Nginx installed and running

---

## Lab — Map Your Domain to Nginx

### Step 1 — Update Your Nginx Server Block

Edit the site config to use your real domain:

```bash
sudo nano /etc/nginx/sites-available/mysite
```

Change `server_name` from the placeholder to your actual domain:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name yourdomain.com www.yourdomain.com;   # ← your real domain

    root /var/www/mysite;
    index index.html;

    access_log /var/log/nginx/mysite-access.log;
    error_log  /var/log/nginx/mysite-error.log;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ /\. {
        deny all;
    }
}
```

> Replace `yourdomain.com` with your actual domain throughout.

### Step 2 — Test and Reload

```bash
sudo nginx -t
# Expected: test is successful

sudo systemctl reload nginx
```

### Step 3 — Verify the Domain Works

```bash
# Test with curl using the Host header (simulates a browser request with your domain)
curl -H "Host: yourdomain.com" http://localhost

# Or, if DNS is resolved, test directly:
curl http://yourdomain.com
curl http://www.yourdomain.com
```

You should see your HTML page.

Also open `http://yourdomain.com` in a browser.

---

## Redirecting www to non-www (or vice versa)

Best practice: pick one canonical URL (`www` or root) and redirect the other.

**Redirect www → root:**

```nginx
# Redirect www to root domain
server {
    listen 80;
    server_name www.yourdomain.com;
    return 301 $scheme://yourdomain.com$request_uri;
}

# Main site on root domain
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/mysite;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
```

Test:
```bash
curl -I http://www.yourdomain.com
# Expected:
# HTTP/1.1 301 Moved Permanently
# Location: http://yourdomain.com/
```

---

## Check nginx is Serving the Right Domain

```bash
# nginx -T shows the entire effective configuration
sudo nginx -T 2>/dev/null | grep server_name

# Expected — your domain should appear:
# server_name yourdomain.com www.yourdomain.com;
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Welcome to nginx" still showing | Old default site still enabled — `sudo rm /etc/nginx/sites-enabled/default` |
| "Could not resolve host" | DNS not propagated yet — check `dig yourdomain.com` |
| Domain resolves but shows wrong content | `server_name` in nginx doesn't match the domain exactly |
| www works but root doesn't (or vice versa) | Make sure both are in `server_name`, or set up a redirect |

---

## Next Step

[06 — SSL with Certbot →](../06-ssl-certbot/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
