# 06 — Package Manager (apt)

## What is apt?

`apt` (Advanced Package Tool) is Ubuntu's package manager. It lets you install, update, and remove software from curated repositories with a single command — no downloading, no manual compilation.

Think of it like an app store for the command line.

---

## How apt Works

```
Your Server  →  apt  →  Ubuntu Package Repositories (on the internet)
                                ↓
                         Downloads .deb package
                                ↓
                         Installs it to /usr/bin, /etc, etc.
```

The list of available packages is stored locally. You update this list with `apt update` before installing anything.

---

## Core Commands

```bash
# Update the local package index (always run before installing)
sudo apt update

# Upgrade all installed packages to their latest versions
sudo apt upgrade -y

# Install a package
sudo apt install nginx

# Install multiple packages at once
sudo apt install curl wget git unzip htop

# Remove a package (keeps config files)
sudo apt remove nginx

# Remove a package AND its config files
sudo apt purge nginx

# Remove unused dependencies
sudo apt autoremove

# Search for a package
apt search nginx

# Show information about a package
apt show nginx

# List all installed packages
apt list --installed

# List installed packages matching a name
apt list --installed | grep nginx
```

---

## Understanding the Output

When you run `sudo apt update`:

```
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Get:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]
Fetched 229 kB in 2s (114 kB/s)
Reading package lists... Done
```

- **Hit** — the repository hasn't changed, nothing to download
- **Get** — new package list downloaded
- **Reading package lists** — building a local index of what's available

When you run `sudo apt upgrade`:
```
The following packages will be upgraded:
  curl libcurl4 openssl
3 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

---

## Lab — Install Essential Tools

SSH into your server:
```bash
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP
```

### Step 1 — Update the Package Index

```bash
sudo apt update
```

Always start with this. It fetches the latest list of available packages.

### Step 2 — Upgrade Installed Packages

```bash
sudo apt upgrade -y
```

The `-y` flag automatically answers "yes" to confirmation prompts.

### Step 3 — Install Common DevOps Tools

```bash
sudo apt install -y curl wget git unzip htop net-tools tree
```

| Package | Purpose |
|---------|---------|
| `curl` | Transfer data from URLs (test APIs, download files) |
| `wget` | Download files from the web |
| `git` | Version control |
| `unzip` | Extract .zip archives |
| `htop` | Interactive process monitor |
| `net-tools` | Network tools including `netstat` |
| `tree` | Display directory structure as a tree |

### Step 4 — Verify Installations

```bash
curl --version | head -1
# Expected: curl 7.81.0 (x86_64-pc-linux-gnu) ...

git --version
# Expected: git version 2.34.1

tree --version
# Expected: tree v2.0.2 ...
```

### Step 5 — Try the Installed Tools

```bash
# Use tree to see a directory structure
tree /etc/nginx 2>/dev/null || echo "nginx not installed yet — will install in Module 04"

# Use curl to test an HTTP request
curl -I https://example.com

# Use htop (press q to quit)
htop
```

### Step 6 — Remove a Package

```bash
# Remove net-tools (we'll use the modern 'ss' command instead)
sudo apt remove -y net-tools

# Verify it's gone
netstat
# Expected: Command 'netstat' not found
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `apt install nginx` without `sudo` | "Permission denied" — always use `sudo apt` |
| Installing without running `apt update` first | You may install an outdated version or get "package not found" |
| `apt upgrade` breaks something | Boot to recovery, or roll back. For production servers, test upgrades first. |
| `apt remove` doesn't remove config files | Use `apt purge` to also remove config files |

---

## Next Step

[07 — Process Manager (systemctl) →](../07-process-manager-systemctl/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
