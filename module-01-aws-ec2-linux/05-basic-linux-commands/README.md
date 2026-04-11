# 05 — Basic Linux Commands & Filesystem Navigation

## Why Linux Commands Matter

Every DevOps task — deploying code, configuring servers, reading logs, managing services — happens through the Linux command line. These commands are your primary tools.

---

## The Linux Filesystem

Linux organises everything in a single tree starting from `/` (the root directory). Unlike Windows with `C:\` and `D:\`, there is only one tree.

```
/
├── etc/        Configuration files for the system and services
├── var/        Variable data: logs, caches, databases
│   └── log/    System and application log files
├── home/       Home directories for regular users
│   └── ubuntu/ Your home directory on Ubuntu EC2
├── root/       Home directory for the root user
├── usr/        User programs and utilities
│   └── bin/    Common commands (ls, cp, grep, etc.)
├── bin/        Essential system commands
├── tmp/        Temporary files (cleared on reboot)
├── opt/        Optional/third-party software
└── proc/       Virtual filesystem: running processes and kernel info
```

Key directories to know:
- `~` is a shortcut for your home directory (`/home/ubuntu`)
- `/etc` is where all service config files live (nginx, ssh, etc.)
- `/var/log` is where all log files live
- `/tmp` is safe for throwing temporary files

---

## Essential Commands

### Navigation

```bash
pwd                     # Print Working Directory — where are you right now?
ls                      # List files in current directory
ls -l                   # Long format (permissions, owner, size, date)
ls -la                  # Long format including hidden files (starting with .)
ls -lh                  # Human-readable file sizes (KB, MB, GB)
cd /etc                 # Change to /etc directory
cd ~                    # Go to home directory
cd ..                   # Go up one level
cd -                    # Go back to previous directory
```

### Files & Directories

```bash
mkdir projects                      # Create a directory
mkdir -p projects/web/html          # Create nested directories at once
touch index.html                    # Create an empty file
cp index.html backup.html           # Copy a file
cp -r projects/ projects-backup/    # Copy a directory recursively
mv index.html /var/www/html/        # Move a file (also used to rename)
mv old-name.txt new-name.txt        # Rename a file
rm file.txt                         # Delete a file
rm -r old-folder/                   # Delete a directory and all its contents
rmdir empty-folder/                 # Delete an empty directory only
```

### Reading Files

```bash
cat file.txt                # Print entire file contents to screen
less file.txt               # Scroll through a file (q to quit)
head file.txt               # Show first 10 lines
head -n 20 file.txt         # Show first 20 lines
tail file.txt               # Show last 10 lines
tail -n 50 file.txt         # Show last 50 lines
tail -f /var/log/syslog     # Follow a file in real time (Ctrl+C to stop)
```

### Writing & Editing Files

```bash
echo "Hello World" > file.txt       # Write to file (overwrites)
echo "Another line" >> file.txt     # Append to file (adds to end)
nano file.txt                       # Open a simple text editor
```

`nano` key bindings:
- `Ctrl+O` — Save (write out)
- `Ctrl+X` — Exit
- `Ctrl+K` — Cut a line
- `Ctrl+U` — Paste a line

### Searching

```bash
grep "error" /var/log/syslog            # Search for "error" in a file
grep -r "server_name" /etc/nginx/       # Search recursively in a directory
grep -i "warning" app.log              # Case-insensitive search
grep -n "failed" auth.log              # Show line numbers
find /var/log -name "*.log"            # Find all .log files under /var/log
find /home -name "*.txt" -type f       # Find only regular files
find / -name "nginx.conf" 2>/dev/null  # Find a file, suppress "permission denied" errors
```

### System Information

```bash
whoami                  # Current username
hostname                # Machine hostname
uname -a                # Full system info (kernel, arch, etc.)
uptime                  # How long the server has been running
date                    # Current date and time
df -h                   # Disk space usage (human readable)
free -h                 # RAM usage (human readable)
lscpu                   # CPU information
```

### Processes

```bash
ps aux                          # List all running processes
ps aux | grep nginx             # Find a specific process
top                             # Interactive process monitor (q to quit)
htop                            # Better interactive monitor (install: sudo apt install htop)
kill 1234                       # Stop process with PID 1234 (graceful)
kill -9 1234                    # Force-kill a process
pkill nginx                     # Kill a process by name
```

### Networking

```bash
ip a                            # Show network interfaces and IPs
curl http://localhost            # Make an HTTP request to localhost
curl -I https://google.com      # Show only response headers
wget https://example.com/file   # Download a file
ss -tlnp                        # Show listening TCP ports and which process owns them
ping google.com                 # Check network reachability (Ctrl+C to stop)
```

### Disk & Permissions Quick View

```bash
ls -lh /var/log/nginx/          # Show file sizes and permissions
du -sh /var/www/                # Total disk usage of a directory
du -sh /*  2>/dev/null          # Disk usage of each top-level directory
```

### Pipes & Redirection

```bash
# Pipe: send output of one command as input to another
ps aux | grep nginx             # Filter process list
cat /etc/passwd | grep ubuntu   # Filter file contents
df -h | grep /dev/xvda          # Filter disk info

# Redirection
echo "hello" > file.txt         # Write to file (overwrite)
echo "world" >> file.txt        # Append to file
cat /etc/nginx/nginx.conf 2>/dev/null       # Suppress errors
ls /nonexistent 2>&1 | grep "No such"      # Redirect stderr to stdout then pipe
```

### Useful Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel running command |
| `Ctrl+D` | Exit current shell session |
| `Ctrl+L` | Clear terminal screen |
| `Tab` | Autocomplete file/command names |
| `↑ / ↓` | Navigate command history |
| `!!` | Repeat last command |
| `sudo !!` | Repeat last command with sudo |

---

## Understanding sudo

`sudo` (Superuser Do) lets a regular user run a command with root (administrator) privileges.

```bash
whoami                      # ubuntu
sudo whoami                 # root

sudo apt update             # Run apt as root
sudo nano /etc/nginx/nginx.conf    # Edit a root-owned config file
sudo -i                     # Switch to root shell (use with caution)
exit                        # Exit root shell, return to ubuntu
```

> Always prefer `sudo command` over switching to root permanently. It's safer and leaves an audit trail in `/var/log/auth.log`.

---

## Next Step

[06 — Package Manager (apt) →](../06-package-manager-apt/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
