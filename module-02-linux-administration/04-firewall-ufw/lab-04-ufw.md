# Lab 04 — UFW Firewall

## Task 1 — Check Initial State

```bash
sudo ufw status
# Expected on fresh instance: Status: inactive
```

---

## Task 2 — Configure and Enable

Apply the standard web server firewall setup:

```bash
# Set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH first (BEFORE enabling!)
sudo ufw allow 22/tcp

# Allow web traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable
sudo ufw enable

# Verify
sudo ufw status verbose
```

---

## Task 3 — Add and Remove Rules

```bash
# Add a temporary rule for a dev server
sudo ufw allow 8080/tcp

# Check it's there
sudo ufw status numbered | grep 8080

# Remove it by number
sudo ufw status numbered
sudo ufw delete $(sudo ufw status numbered | grep 8080 | awk '{print $1}' | tr -d '[]')

# Verify it's gone
sudo ufw status | grep 8080
# Expected: (no output)
```

---

## Task 4 — Restrict SSH to Your IP Only

For real security, SSH must be locked to your IP in **both** places — UFW (OS firewall) **and** your AWS Security Group. Locking only one still leaves the door open through the other.

### Step A — Update UFW

```bash
MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "Your IP: $MY_IP"

# Remove the open SSH rule
sudo ufw delete allow 22/tcp

# Add restricted SSH rule (your IP only)
sudo ufw allow from "$MY_IP" to any port 22 proto tcp

# Verify
sudo ufw status verbose | grep 22
```

### Step B — Update the AWS Security Group

**Console:**
1. EC2 → left sidebar → **Security Groups**
2. Click your instance's security group (e.g. `devops-lab-sg`)
3. **Inbound rules** tab → **Edit inbound rules**
4. Find the SSH (port 22) rule
5. Change **Source** from `0.0.0.0/0` to **My IP** — the Console auto-fills your current IP
6. Click **Save rules**

**CLI** (from your local machine):
```bash
# Get your security group ID
SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=devops-lab-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "Updating SG $SG_ID to restrict SSH to $MY_IP"

# Remove the open SSH rule
aws ec2 revoke-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

# Add your IP only
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "$MY_IP/32"

# Confirm
aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`22\`]" \
  --output table
```

> If your IP changes later (e.g. you switch networks), update both places again. Use `curl -s https://checkip.amazonaws.com` to get the new IP.

---

## Task 5 — UFW Logging

```bash
# Enable logging
sudo ufw logging on

# Check current log level
sudo ufw status verbose | grep Logging

# Generate some denied traffic by testing a blocked port
# (from another system or using nc locally to a blocked port)

# View the UFW log
sudo tail -n 20 /var/log/ufw.log
```

---

## Reflection

1. You have UFW enabled blocking port 3306 (MySQL). Your Security Group allows port 3306. Can someone connect to MySQL from the internet?

2. Your Security Group blocks port 80. UFW allows port 80. Can someone reach your website?

3. Why should you always run `sudo ufw allow 22` before `sudo ufw enable`?

**Answers:**
1. No — UFW blocks it at the OS level even if Security Group allows it
2. No — Security Group is the first gate; if it's closed, traffic never reaches UFW
3. Because `ufw enable` activates the default "deny incoming" policy immediately — your current SSH session won't be affected (it's already established), but new connections would be blocked


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
