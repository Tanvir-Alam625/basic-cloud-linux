# 04 — Firewall (UFW)

## What is UFW?

UFW (Uncomplicated Firewall) is a frontend for `iptables` — Linux's built-in packet filtering system. UFW makes it significantly easier to write firewall rules without needing to understand the complex iptables syntax.

**The relationship:**
- Security Groups (AWS) — controls traffic at the AWS network level, *before* it reaches your server
- UFW — controls traffic at the OS level, *after* it reaches the server's network interface

Both should be configured. Security Groups are your first line of defense; UFW is your second.

---

## Core UFW Commands

```bash
# Check UFW status and rules
sudo ufw status

# Check status with rule numbers
sudo ufw status numbered

# Verbose status: full details including defaults
sudo ufw status verbose

# Enable the firewall
sudo ufw enable

# Disable the firewall
sudo ufw disable

# Reset all rules to default (deletes everything)
sudo ufw reset
```

---

## Managing Rules

```bash
# Allow by service name (UFW knows common services)
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Allow by port number
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# Allow by port/protocol
sudo ufw allow 22/tcp
sudo ufw allow 53/udp

# Allow a port range
sudo ufw allow 8000:9000/tcp

# Allow from a specific IP
sudo ufw allow from 1.2.3.4

# Allow from a specific IP on a specific port
sudo ufw allow from 1.2.3.4 to any port 22

# Deny a port
sudo ufw deny 3306       # Block MySQL from outside

# Delete a rule by number
sudo ufw status numbered
sudo ufw delete 3         # Deletes rule number 3

# Delete a rule by spec
sudo ufw delete allow 8080
```

---

## UFW Default Policies

By default:
- Incoming: **DENY** all (nothing gets in unless you explicitly allow it)
- Outgoing: **ALLOW** all (your server can connect out to anything)

This is the correct default for a web server. You explicitly open only ports you need.

```bash
# View default policies
sudo ufw status verbose | grep "Default"

# Set defaults explicitly
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

---

## Lab — Configure UFW for a Web Server

### Step 1 — Check Current Status

```bash
sudo ufw status
```

On a fresh Ubuntu EC2, UFW is typically **inactive** (disabled).

### Step 2 — Set Default Policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Step 3 — Allow SSH Before Enabling

**Critical:** Always allow SSH before enabling UFW — otherwise you'll lock yourself out.

```bash
sudo ufw allow 22/tcp
```

Or using the service name:
```bash
sudo ufw allow OpenSSH
```

### Step 4 — Allow Web Traffic

```bash
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS
```

Or using the "Nginx Full" profile (allows both 80 and 443):
```bash
sudo ufw allow 'Nginx Full'
```

Available app profiles:
```bash
sudo ufw app list
```

### Step 5 — Enable UFW

```bash
sudo ufw enable
```

Output:
```
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
```

### Step 6 — Verify Rules

```bash
sudo ufw status verbose
```

Expected:
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
443/tcp (v6)               ALLOW IN    Anywhere (v6)
```

### Step 7 — Test It

```bash
# HTTP should work
curl -I http://localhost

# A blocked port should refuse connections
nc -zv localhost 3306 2>&1
# Expected: Connection refused
```

---

## UFW Logging

```bash
# Enable logging (low = denied packets only)
sudo ufw logging on

# Set log level
sudo ufw logging low    # just blocked connections
sudo ufw logging medium # blocked + allowed
sudo ufw logging high   # very verbose

# View firewall log
sudo tail -f /var/log/ufw.log
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Enabled UFW without allowing SSH — locked out | Use EC2 Instance Connect in the AWS Console, then `sudo ufw allow 22` |
| Port 80 blocked — website unreachable | `sudo ufw allow 80/tcp` |
| Forgot to enable — rules have no effect | `sudo ufw enable` |
| UFW and Security Group both needed | Yes — both must allow the port for traffic to flow |

---

## Next Step

[05 — Cronjobs →](../05-cronjobs/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
