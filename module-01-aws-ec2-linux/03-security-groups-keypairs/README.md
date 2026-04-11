# 03 — Security Groups & Key Pairs

## What is a Security Group?

A Security Group acts as a **virtual firewall** for your EC2 instance. It controls what network traffic is allowed in (inbound) and out (outbound) of your instance.

Key things to understand:
- Security Groups are **stateful** — if you allow inbound traffic on port 80, the response is automatically allowed out, even without an explicit outbound rule
- Rules are **allow-only** — you can't write a "deny" rule; anything not listed is blocked by default
- Multiple instances can share one Security Group
- One instance can have multiple Security Groups

---

## Inbound vs Outbound Rules

| Direction | Meaning | Default |
|-----------|---------|---------|
| Inbound | Traffic coming **into** your instance | All blocked |
| Outbound | Traffic going **out** from your instance | All allowed |

---

## Common Ports to Know

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH — remote terminal access |
| 80 | TCP | HTTP — unencrypted web traffic |
| 443 | TCP | HTTPS — encrypted web traffic |
| 3000 | TCP | Common Node.js / app server port |
| 5432 | TCP | PostgreSQL database |
| 3306 | TCP | MySQL database |

---

## What is a Key Pair?

A Key Pair is an SSH authentication mechanism. It consists of:
- **Private key** (`.pem` file) — stays on your local machine, never shared
- **Public key** — stored by AWS and placed on the EC2 instance at launch

When you SSH in, your local machine presents the private key and the server verifies it against the stored public key. No password needed.

Think of it like a lock and key: the public key is the lock installed on the server, and your `.pem` file is the only key that opens it.

---

## Lab — Manage Security Groups

### Task 1 — Inspect Your Existing Security Group

In the EC2 Console → left sidebar → **Security Groups** → click `devops-lab-sg`.

Review the **Inbound rules** tab:

```
Type     Protocol   Port   Source          Description
SSH      TCP        22     My IP (x.x.x.x) SSH access
HTTP     TCP        80     0.0.0.0/0       Web traffic
HTTPS    TCP        443    0.0.0.0/0       Secure web traffic
```

### Task 2 — Edit an Inbound Rule

Simulate one of the most common real-world tasks: your IP changed and you can no longer SSH in.

1. Select the SSH rule → click **Edit inbound rules**
2. Change the source from your current IP to **My IP** (AWS auto-detects your current IP)
3. Click **Save rules**

### Task 3 — Add a Custom Port Rule

Add a rule for an application server running on port 3000:

1. Click **Edit inbound rules** → **Add rule**
2. Set:
   - Type: Custom TCP
   - Port range: 3000
   - Source: My IP
   - Description: App server
3. Save rules

### Task 4 — Remove the Port 3000 Rule

Clean up: remove the rule you just added.

1. Edit inbound rules
2. Click **Delete** (🗑) on the port 3000 rule
3. Save rules

---

## Lab — Manage Key Pairs

### Inspect Your Key Pair

In EC2 Console → left sidebar → **Key Pairs**

You'll see your `devops-lab-key` with:
- Type: RSA
- Fingerprint: a unique hash to verify the key

### Verify Key File Permissions Locally

```bash
ls -la ~/.ssh/devops-lab-key.pem
```

Expected output:
```
-r--------  1 youruser  staff  1675 Jan 1 12:00 /Users/youruser/.ssh/devops-lab-key.pem
```

The permissions must be `-r--------` (400). If they're different, fix with:
```bash
chmod 400 ~/.ssh/devops-lab-key.pem
```

If you see `-rw-r--r--` or `-rw-------`, SSH will refuse to use the key and show "WARNING: UNPROTECTED PRIVATE KEY FILE!"

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Connection refused" on port 22 | SSH inbound rule is missing or wrong IP |
| "Connection timed out" | Security Group has no SSH rule at all, or your IP changed |
| "WARNING: UNPROTECTED PRIVATE KEY FILE" | Run `chmod 400 ~/.ssh/devops-lab-key.pem` |
| Forgot which key pair to use | Check instance details tab → Key pair name |
| Locked yourself out by deleting SSH rule | Use **EC2 Instance Connect** in the AWS Console as a backup |

---

## EC2 Instance Connect (Emergency Backup)

If you can't SSH, you can use **EC2 Instance Connect** from the AWS Console:

1. Select your instance → click **Connect**
2. Choose **EC2 Instance Connect**
3. Click **Connect** — a browser-based terminal opens

This only works on Ubuntu and Amazon Linux instances with the `ec2-instance-connect` package installed (Ubuntu 22.04 has it by default).

---

## Next Step

[04 — SSH Connection →](../04-ssh-connection/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
