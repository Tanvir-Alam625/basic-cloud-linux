# 01 — File Permissions & Ownership

## Why Permissions Matter

Linux is a multi-user system. File permissions control:
- Who can **read** a file
- Who can **write** (modify) a file
- Who can **execute** a file or enter a directory

Getting permissions wrong is one of the most common causes of "Permission denied" errors — and setting them too open is a security risk.

---

## The Permission Model

Every file and directory has three permission sets:

```
-rwxr-xr--  1  ubuntu  www-data  1234  Apr 11 12:00  script.sh
```

Breaking this down:

```
- rwx r-x r--
│ │   │   │
│ │   │   └── Other (everyone else): read only
│ │   └────── Group (www-data): read + execute
│ └────────── Owner (ubuntu): read + write + execute
└──────────── File type: - = file, d = directory, l = symlink
```

### Permission Characters

| Symbol | Meaning |
|--------|---------|
| `r` | Read — view file contents, or list directory |
| `w` | Write — modify file contents, or create/delete files in directory |
| `x` | Execute — run as a program, or enter (cd into) a directory |
| `-` | Permission not granted |

---

## Numeric (Octal) Permissions

Each permission set can also be written as a number:

| Binary | Octal | Meaning |
|--------|-------|---------|
| 000 | 0 | --- no permissions |
| 001 | 1 | --x execute only |
| 010 | 2 | -w- write only |
| 011 | 3 | -wx write + execute |
| 100 | 4 | r-- read only |
| 101 | 5 | r-x read + execute |
| 110 | 6 | rw- read + write |
| 111 | 7 | rwx full permissions |

Common permission combinations:

| Numeric | Symbolic | Typical Use |
|---------|----------|-------------|
| 400 | r-------- | SSH private key (.pem) |
| 600 | rw------- | Private files (secrets, .env) |
| 644 | rw-r--r-- | Public config files, web content |
| 755 | rwxr-xr-x | Executable scripts, directories |
| 777 | rwxrwxrwx | Everyone can do anything — **avoid this** |

---

## chmod — Change Permissions

```bash
# Numeric mode
chmod 755 script.sh          # owner: rwx, group: r-x, other: r-x
chmod 644 index.html         # owner: rw-, group: r--, other: r--
chmod 400 private.pem        # owner: r--, group: ---, other: ---
chmod 600 .env               # owner: rw-, group: ---, other: ---

# Recursive — apply to directory and all its contents
chmod -R 755 /var/www/html/

# Symbolic mode
chmod u+x script.sh          # add execute for user (owner)
chmod g-w file.txt           # remove write for group
chmod o-r secret.txt         # remove read for others
chmod a+r public.txt         # add read for all (user, group, other)
```

---

## chown — Change Owner

```bash
# Change owner
sudo chown ubuntu file.txt

# Change owner and group
sudo chown ubuntu:www-data file.txt

# Recursive — change owner of directory and everything inside
sudo chown -R ubuntu:www-data /var/www/html/

# Change only the group
sudo chgrp www-data /var/www/html/
```

---

## Real-World Scenarios

### Web Server Files

Nginx runs as the `www-data` user. For it to serve files from `/var/www/html/`:
```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### Shell Scripts

Scripts must be executable before you can run them with `./`:
```bash
chmod +x deploy.sh
./deploy.sh
```

### Private Config Files

Files containing passwords or tokens:
```bash
chmod 600 .env              # only owner can read/write
chmod 600 ~/.ssh/config
```

---

## Lab — File Permissions

### Step 1 — Inspect Permissions

```bash
ls -la /etc/nginx/nginx.conf
# Expected: -rw-r--r-- 1 root root 1447 ... /etc/nginx/nginx.conf
# root owns it, everyone else can only read it

ls -la ~/.ssh/
# Expected: your .pem key should be -r-------- (400)
```

### Step 2 — Create and Restrict a File

```bash
# Create a file with sensitive content
echo "DB_PASSWORD=supersecret123" > ~/secret.txt

# Check default permissions
ls -l ~/secret.txt
# Typically: -rw-rw-r-- (664) — group and others can read it! Bad!

# Restrict it
chmod 600 ~/secret.txt
ls -l ~/secret.txt
# Expected: -rw------- — only you can read/write
```

### Step 3 — Make a Script Executable

```bash
# Create a script
echo '#!/bin/bash
echo "Hello, You made this script executable!"' > ~/hello.sh

# Try running it — will fail
./hello.sh
# Expected: bash: ./hello.sh: Permission denied

# Add execute permission
chmod +x ~/hello.sh

# Run it
./hello.sh
# Expected: Hello, You made this script executable!
```

### Step 4 — Change Ownership

```bash
# Create a file and check ownership
touch ~/owned-by-me.txt
ls -l ~/owned-by-me.txt
# Expected: -rw-rw-r-- 1 ubuntu ubuntu ...

# Change owner to root
sudo chown root ~/owned-by-me.txt
ls -l ~/owned-by-me.txt
# Expected: -rw-rw-r-- 1 root ubuntu ...

# Try to delete it — will fail (you don't own it)
rm ~/owned-by-me.txt
# rm: cannot remove: Permission denied

# Change it back so you can clean up
sudo chown ubuntu ~/owned-by-me.txt
rm ~/owned-by-me.txt
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `chmod 777` on web files | Use 755 for directories, 644 for files |
| Nginx "403 Forbidden" | Web files owned by wrong user or permissions too restrictive. Run `sudo chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html` |
| Script won't run (`Permission denied`) | Missing execute bit: `chmod +x script.sh` |
| SSH "WARNING: UNPROTECTED PRIVATE KEY FILE" | `chmod 400 ~/.ssh/key.pem` |

---

## Next Step

[02 — Environment Variables →](../02-environment-variables/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
