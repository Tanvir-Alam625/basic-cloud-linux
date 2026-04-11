# Lab 01 — File Permissions & Ownership

## Task 1 — Read Existing Permissions

```bash
# System directories and their permissions
ls -ld /etc /var/log /tmp /home
```

Expected:
```
drwxr-xr-x 102 root root  4096 Apr 11 /etc
drwxrwxr-x  11 root syslog 4096 Apr 11 /var/log
drwxrwxrwt  13 root root  4096 Apr 11 /tmp
drwxr-xr-x   3 root root  4096 Apr 11 /home
```

Note the sticky bit `t` on `/tmp` — it means anyone can create files, but only the owner can delete their own files.

---

## Task 2 — Numeric Permission Practice

Without running commands, work out the permission string for each:

| Numeric | Your Answer | Check |
|---------|-------------|-------|
| 755 | ? | `rwxr-xr-x` |
| 644 | ? | `rw-r--r--` |
| 600 | ? | `rw-------` |
| 400 | ? | `r--------` |
| 777 | ? | `rwxrwxrwx` |

Verify your answers:
```bash
touch testfile
chmod 755 testfile; ls -l testfile | awk '{print $1}'
chmod 644 testfile; ls -l testfile | awk '{print $1}'
chmod 600 testfile; ls -l testfile | awk '{print $1}'
chmod 400 testfile; ls -l testfile | awk '{print $1}'
rm testfile
```

---

## Task 3 — Secure File Workflow

```bash
# Simulate a .env file with secrets
cat > ~/app.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
DB_USER=appuser
DB_PASSWORD=MySecret@2026
SECRET_KEY=abc123xyz
EOF

# Check current permissions
ls -l ~/app.env
# Likely world-readable — bad!

# Secure it: only owner can read/write
chmod 600 ~/app.env
ls -l ~/app.env
# Expected: -rw-------

# Try reading as another user context (see what others see)
# On a real server with multiple users, others would be blocked.
# You can simulate with sudo -u nobody cat ~/app.env
# Expected: Permission denied
```

---

## Task 4 — Web Root Permissions

```bash
# Create a demo web directory structure
sudo mkdir -p /var/www/mysite
sudo touch /var/www/mysite/index.html
echo "<h1>Hello</h1>" | sudo tee /var/www/mysite/index.html

# Check current ownership
ls -la /var/www/mysite/

# Set correct web server ownership
sudo chown -R www-data:www-data /var/www/mysite/

# Set permissions correctly:
#   Directories: 755 (rwxr-xr-x) — nginx must be able to enter them
#   Files:       644 (rw-r--r--) — nginx reads, no one executes HTML/CSS
# Using chmod -R 755 on everything makes files executable — avoid this.
find /var/www/mysite -type d | xargs sudo chmod 755
find /var/www/mysite -type f | xargs sudo chmod 644

# Verify
ls -la /var/www/mysite/
# Expected: drwxr-xr-x  www-data www-data  .
#           -rw-r--r--  www-data www-data  index.html
```

---

## Task 5 — Find Files with Specific Permissions

```bash
# Find world-writable files (potential security risk)
find /var/www -perm -o+w -type f 2>/dev/null

# Find SUID files (run as file owner, not the caller — review these)
find /usr/bin -perm /4000 -type f 2>/dev/null | head -10

# Find files owned by root with world read
find /etc -maxdepth 1 -user root -perm -o+r -type f 2>/dev/null | head -10
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
