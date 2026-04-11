# Lab 04 — Linux Commands & Filesystem Navigation

SSH into your EC2 instance before starting.

```bash
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP
```

---

## Part A — Navigation

```bash
# Where are you?
pwd
# Expected: /home/ubuntu

# List home directory contents
ls -la ~

# Explore the filesystem root
ls /

# Go to /etc and look around
cd /etc
pwd
ls -l | head -20

# Return home
cd ~
```

---

## Part B — Create a Working Directory Structure

```bash
# Create a project folder with sub-directories
mkdir -p ~/devops-practice/scripts
mkdir -p ~/devops-practice/configs
mkdir -p ~/devops-practice/logs

# Verify
ls -la ~/devops-practice/

# Expected:
# drwxrwxr-x 2 ubuntu ubuntu 4096 Apr 11 12:00 configs
# drwxrwxr-x 2 ubuntu ubuntu 4096 Apr 11 12:00 logs
# drwxrwxr-x 2 ubuntu ubuntu 4096 Apr 11 12:00 scripts
```

---

## Part C — Create and Read Files

```bash
cd ~/devops-practice

# Create files with content
echo "This is my first DevOps practice file" > scripts/hello.sh
echo "server_name=devops-lab" > configs/app.conf
echo "APP_ENV=production" >> configs/app.conf
echo "APP_PORT=3000" >> configs/app.conf

# Read them
cat scripts/hello.sh
cat configs/app.conf

# Expected for app.conf:
# server_name=devops-lab
# APP_ENV=production
# APP_PORT=3000
```

---

## Part D — Copy, Move, Rename

```bash
# Copy the config file
cp configs/app.conf configs/app.conf.backup

# Verify both exist
ls -lh configs/

# Rename the backup
mv configs/app.conf.backup configs/app.conf.bak

# Move a file to another folder
cp configs/app.conf logs/current-config.txt

# Verify
ls logs/
```

---

## Part E — Search with grep and find

```bash
# Search inside a file
grep "APP" configs/app.conf
# Expected:
# APP_ENV=production
# APP_PORT=3000

# Search for files in your practice folder
find ~/devops-practice -type f

# Expected:
# /home/ubuntu/devops-practice/scripts/hello.sh
# /home/ubuntu/devops-practice/configs/app.conf
# /home/ubuntu/devops-practice/configs/app.conf.bak
# /home/ubuntu/devops-practice/logs/current-config.txt

# Find all .log files in /var/log
find /var/log -name "*.log" 2>/dev/null | head -10

# Search system logs for SSH-related entries
grep -i "ssh" /var/log/auth.log | tail -5
```

---

## Part F — Disk and Process Info

```bash
# Disk space
df -h

# Expected output (example):
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/xvda1      7.6G  1.9G  5.7G  25% /
# tmpfs           483M     0  483M   0% /dev/shm

# RAM usage
free -h

# Expected:
#                total    used    free  shared  buff/cache   available
# Mem:           964Mi   243Mi   298Mi   1.0Mi       422Mi       571Mi

# Running processes (first 10)
ps aux | head -10

# What's listening on the network?
ss -tlnp
```

---

## Part G — Cleanup

```bash
# Remove a single file
rm ~/devops-practice/logs/current-config.txt

# Remove a directory and all its contents
rm -r ~/devops-practice/

# Verify it's gone
ls ~
```

---

## Common Mistakes

| Mistake | What Happens | Correct Approach |
|---------|-------------|-----------------|
| `rm -r /` | Deletes the entire filesystem | Never run this. Always double-check the path before `rm -r` |
| `cd etc` | Error: no such file (missing `/`) | Use `cd /etc` for absolute paths |
| `cat` a binary file | Garbled output, terminal may break | Use `file filename` first to check file type |
| Forgetting `sudo` | "Permission denied" on system files | Prefix with `sudo` for root-owned paths |


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
