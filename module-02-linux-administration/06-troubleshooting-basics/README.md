# 06 — Troubleshooting Basics

## The DevOps Troubleshooting Mindset

When something breaks, work from the outside in:

1. **Is the server reachable?** (network/DNS)
2. **Is the service running?** (systemctl)
3. **Is it listening on the right port?** (ss/netstat)
4. **Is the firewall blocking it?** (UFW/Security Group)
5. **What do the logs say?** (journalctl/log files)
6. **Is there a config error?** (nginx -t, service-specific test)
7. **Is the server out of resources?** (disk, memory, CPU)

---

## Disk Space

Running out of disk space is one of the most common causes of service failures.

```bash
# Overall disk usage
df -h

# Output explained:
# Filesystem     Size  Used Avail Use%  Mounted on
# /dev/xvda1     7.6G  6.1G  1.5G  81%  /    ← only 19% left — getting full

# Which directory is using the most space?
du -sh /* 2>/dev/null | sort -rh | head -10

# Drill into the largest directory
du -sh /var/log/* 2>/dev/null | sort -rh | head -10

# Find the largest files on the system
find / -type f -size +100M 2>/dev/null | head -10
```

### What to do when disk is full

```bash
# 1. Clear apt cache
sudo apt clean
sudo apt autoremove -y

# 2. Remove old compressed logs
sudo find /var/log -name "*.gz" -delete

# 3. Clear the systemd journal (keep last 2 days)
sudo journalctl --vacuum-time=2d

# 4. Truncate a large log file (don't delete — service may have handle open)
sudo truncate -s 0 /var/log/nginx/access.log
```

---

## Memory

```bash
# Memory overview
free -h

# Output explained:
#               total   used   free  shared  buff/cache  available
# Mem:          964Mi  750Mi   50Mi    1Mi       163Mi      163Mi
# Swap:           0B     0B     0B

# Total = used + free + buff/cache
# "available" is what new processes can actually use (free + reclaimable cache)

# Top memory-consuming processes
ps aux --sort=-%mem | head -10

# How much memory does a specific process use?
ps aux | grep nginx
```

---

## CPU and Load

```bash
# Load average (over 1, 5, 15 minutes)
uptime
# 14:00:01 up 2 days,  load average: 0.15, 0.10, 0.08
# For a 1-core server, load > 1.0 means it's overloaded

# CPU usage per process (interactive — press q to quit)
top

# Better interactive view (install: sudo apt install htop)
htop

# Top 10 CPU-hungry processes right now
ps aux --sort=-%cpu | head -10
```

---

## Processes

```bash
# Find a specific process
ps aux | grep nginx

# Get the PID of a process by name
pgrep nginx

# Kill a process by PID (graceful)
kill 1234

# Force kill (when graceful fails)
kill -9 1234

# Kill by name
pkill nginx
sudo pkill -9 nginx

# What is a PID's working directory?
ls -la /proc/1234/cwd

# What files does it have open?
sudo lsof -p 1234
```

---

## Ports and Network

```bash
# What's listening on which port?
ss -tlnp

# Expected output:
# State  Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
# LISTEN 0       511     0.0.0.0:80          0.0.0.0:*          users:(("nginx",pid=1234))
# LISTEN 0       128     0.0.0.0:22          0.0.0.0:*          users:(("sshd",pid=1235))

# Is a specific port open?
ss -tlnp | grep :80

# Which process is using port 80?
sudo lsof -i :80

# Test connectivity to a remote host
nc -zv google.com 443
# Expected: Connection to google.com port 443 [tcp/https] succeeded!

# Trace network route to a host
traceroute google.com
```

---

## Service Failures

```bash
# Is the service running?
sudo systemctl status nginx

# What caused it to fail?
sudo journalctl -u nginx -n 50 --no-pager

# Test nginx config for syntax errors
sudo nginx -t

# Expected good output:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# Expected bad output:
# nginx: [emerg] "server" directive is not allowed here in /etc/nginx/sites-enabled/mysite:3
# nginx: configuration file /etc/nginx/nginx.conf test failed
```

---

## Connectivity Troubleshooting Checklist

When a website is not loading:

```bash
# Step 1: Is nginx running?
sudo systemctl status nginx

# Step 2: Is it listening on port 80?
ss -tlnp | grep :80

# Step 3: Does it respond locally?
curl -I http://localhost

# Step 4: Is UFW blocking port 80?
sudo ufw status | grep 80

# Step 5: Is the AWS Security Group allowing port 80?
#
# Console: EC2 → Instances → click instance → Security tab →
#          Security groups → click the group → Inbound rules
#          Confirm an HTTP rule exists: Port 80, Source 0.0.0.0/0
#
# CLI (run from your local machine, not the EC2 instance):
# aws ec2 describe-security-groups \
#   --filters "Name=ip-permission.from-port,Values=80" \
#             "Name=ip-permission.to-port,Values=80" \
#             "Name=ip-permission.protocol,Values=tcp" \
#   --query "SecurityGroups[].{Name:GroupName,Rules:IpPermissions[?FromPort==\`80\`]}" \
#   --output json
# If port 80 is not present, add it:
# aws ec2 authorize-security-group-ingress --group-id sg-XXXX \
#   --protocol tcp --port 80 --cidr 0.0.0.0/0

# Step 6: What do the error logs say?
sudo tail -n 30 /var/log/nginx/error.log
```

---

## Lab — Diagnose a Real Problem

### Simulate and Fix a Broken nginx

```bash
# 1. Introduce a config error
echo "invalid_directive on;" | sudo tee /etc/nginx/conf.d/broken.conf

# 2. Try to restart nginx
sudo systemctl restart nginx
# This will FAIL

# 3. Check what happened
sudo systemctl status nginx
# You'll see: Active: failed

# 4. Read the error
sudo journalctl -u nginx -n 20 --no-pager
# You'll see: [emerg] unknown directive "invalid_directive"

# 5. Fix it
sudo rm /etc/nginx/conf.d/broken.conf

# 6. Verify the config is clean
sudo nginx -t
# Expected: test is successful

# 7. Start nginx
sudo systemctl start nginx
sudo systemctl status nginx
# Expected: Active: active (running)
```

### Simulate Disk Usage Check

```bash
# Check disk
df -h /

# Simulate what to do if disk were at 90%:
du -sh /var/log/* 2>/dev/null | sort -rh | head -5
sudo journalctl --disk-usage
```

---

## Common Mistakes

| Symptom | First Thing to Check |
|---------|---------------------|
| Website not loading | `systemctl status nginx` → `ss -tlnp` → UFW → Security Group |
| "502 Bad Gateway" | Backend app is not running on the proxied port |
| "504 Gateway Timeout" | Backend app is running but not responding fast enough |
| SSH works, web doesn't | Port 80/443 UFW or Security Group rule |
| Nothing works, can't SSH | Instance may be stopped, or your IP changed and the Security Group blocks new IP |
| Everything keeps crashing | Check `df -h` — disk full, or `free -h` — out of memory |

---

## Next Step

Proceed to [Module 03 — IAM & AWS CLI →](../../module-03-iam-and-aws-cli/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
