# Lab 05 — Package Manager (apt)

## Task 1 — Update and Upgrade

```bash
# Step 1: Update package index
sudo apt update

# Step 2: See what can be upgraded
apt list --upgradable 2>/dev/null

# Step 3: Upgrade everything
sudo apt upgrade -y
```

---

## Task 2 — Install Packages

```bash
sudo apt install -y curl wget git unzip htop tree
```

Verify each:
```bash
which curl wget git unzip htop tree
```

Expected: one path per line, e.g. `/usr/bin/curl`

---

## Task 3 — Search and Inspect Packages

```bash
# Search for nginx (we'll install it in Module 04)
apt search nginx | head -10

# Show details about a package before installing
apt show curl
```

`apt show curl` expected output:
```
Package: curl
Version: 7.81.0-1ubuntu1.10
Priority: optional
Section: web
Maintainer: Ubuntu Developers
Installed-Size: 411 kB
Depends: libc6 (>= 2.17), libcurl4 (= 7.81.0-1ubuntu1.10), zlib1g ...
Homepage: https://curl.se
Download-Size: 194 kB
APT-Sources: http://archive.ubuntu.com/ubuntu jammy/main amd64 Packages
Description: command line tool for transferring data with URL syntax
```

---

## Task 4 — List and Audit Installed Packages

```bash
# Count installed packages
apt list --installed 2>/dev/null | wc -l

# Look for a specific installed package
apt list --installed 2>/dev/null | grep curl

# Expected: curl/jammy-updates,jammy-security,now 7.81.0-... [installed]
```

---

## Task 5 — Purge vs Remove

```bash
# Install a test package
sudo apt install -y sl      # 'sl' is a fun train animation

# Run it
sl

# Remove it (config files stay if any)
sudo apt remove -y sl

# Try running it — should be gone
sl
# Expected: Command 'sl' not found

# Purge is the same but also removes any leftover config files
# sudo apt purge -y package-name

# Clean up unused dependencies after removals
sudo apt autoremove -y
```

---

## Task 6 — Understand Where Files Are Installed

```bash
# Where did curl get installed?
which curl
# Expected: /usr/bin/curl

# What files does the curl package own?
dpkg -L curl | head -20

# What package does a file belong to?
dpkg -S /usr/bin/curl
# Expected: curl: /usr/bin/curl
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
