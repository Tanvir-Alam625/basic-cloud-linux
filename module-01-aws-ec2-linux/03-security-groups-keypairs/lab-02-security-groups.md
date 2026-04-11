# Lab 02 — Security Groups

Each task shows both methods — **Console (GUI)** and **CLI**.

> **Variables from Lab 01** — if you started a new terminal session, restore them:
> ```bash
> SG_ID=$(aws ec2 describe-security-groups \
>   --filters "Name=group-name,Values=devops-lab-sg" \
>   --query "SecurityGroups[0].GroupId" --output text)
> INSTANCE_ID=$(aws ec2 describe-instances \
>   --filters "Name=tag:Name,Values=devops-lab-server" \
>   --query "Reservations[0].Instances[0].InstanceId" --output text)
> ```

---

## Task 1 — Create a Second Security Group from Scratch

Practice the full create + add-rules workflow independently, without the Launch Wizard.

### Console

1. EC2 → **Security Groups** → **Create security group**
2. Fill in the form:

| Field | Value |
|-------|-------|
| Security group name | `webserver-sg` |
| Description | Web server security group |
| VPC | Default VPC |

3. Add inbound rules:

| Type | Port | Source | Description |
|------|------|--------|-------------|
| SSH | 22 | My IP | Admin SSH |
| HTTP | 80 | 0.0.0.0/0 | Public web |
| HTTPS | 443 | 0.0.0.0/0 | Public HTTPS |

4. Leave outbound rules as default (All traffic — Anywhere)
5. Click **Create security group**
6. Note the Security group ID from the confirmation page

### CLI

```bash
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)

WEBSG_ID=$(aws ec2 create-security-group \
  --group-name webserver-sg \
  --description "Web server security group" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)
echo "webserver-sg ID: $WEBSG_ID"

MY_IP=$(curl -s https://checkip.amazonaws.com)

aws ec2 authorize-security-group-ingress --group-id "$WEBSG_ID" \
  --protocol tcp --port 22 --cidr "$MY_IP/32"

aws ec2 authorize-security-group-ingress --group-id "$WEBSG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id "$WEBSG_ID" \
  --protocol tcp --port 443 --cidr 0.0.0.0/0

aws ec2 describe-security-groups \
  --group-ids "$WEBSG_ID" \
  --query "SecurityGroups[].IpPermissions[].{Protocol:IpProtocol,Port:FromPort,CIDR:IpRanges[0].CidrIp}" \
  --output table
```

Expected:
```
+----------+------+------------------------+
| Protocol | Port |         CIDR           |
+----------+------+------------------------+
|  tcp     |  22  |  X.X.X.X/32           |
|  tcp     |  80  |  0.0.0.0/0            |
|  tcp     |  443 |  0.0.0.0/0            |
+----------+------+------------------------+
```

---

## Task 2 — Replace the Security Group on Your Instance

### Console

1. EC2 → **Instances** → select `devops-lab-server`
2. **Actions** → **Security** → **Change security groups**
3. In **Associated security groups**, search for and add `webserver-sg`
4. Remove `devops-lab-sg` by clicking the **×** next to it
5. Click **Save**
6. Refresh the instance detail panel — the **Security groups** field should now show only `webserver-sg`

### CLI

```bash
# --groups replaces ALL security groups on the instance at once.
# Any group not listed here is removed — include every group you want to keep active.
aws ec2 modify-instance-attribute \
  --instance-id "$INSTANCE_ID" \
  --groups "$WEBSG_ID"

# Confirm
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].SecurityGroups[].{Name:GroupName,ID:GroupId}" \
  --output table
```

Expected:
```
+------------------+--------------+
|        ID        |     Name     |
+------------------+--------------+
|  sg-0abc123      | webserver-sg |
+------------------+--------------+
```

---

## Task 3 — Test Port Reachability from Your Local Machine

Once SSH is working (next lab), confirm the firewall rules allow or block specific ports:

```bash
# From your LOCAL machine — not the EC2 instance
nc -zv YOUR_SERVER_IP 80
```

Expected (port open):
```
Connection to 54.123.45.67 port 80 [tcp/http] succeeded!
```

Expected (port blocked):
```
nc: connectx to 54.123.45.67 port 80 (tcp) failed: Connection refused
```

---

## Task 4 — Inspect Security Group Rules

### Console

1. EC2 → **Security Groups**
2. Click `webserver-sg`
3. Open the **Inbound rules** tab — verify SSH (22), HTTP (80), HTTPS (443) are present
4. Open the **Outbound rules** tab — confirm All traffic is allowed

### CLI

```bash
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=webserver-sg" \
  --query "SecurityGroups[].{Name:GroupName,ID:GroupId,Rules:IpPermissions}" \
  --output json
```

---

## Reflection Questions

1. What happens if you remove the HTTP (port 80) rule while Nginx is running — can you still reach the website?
2. Why is it safer to restrict SSH to "My IP" instead of `0.0.0.0/0`?
3. If your home IP changes (e.g. you reconnect to a different network), what do you need to update?
4. The CLI `--groups` flag replaces all groups at once. What is the risk if you forget to include an existing group in the list?

---

## Task 1 — Create a Second Security Group from Scratch

Practice the full create + rule workflow independently:

```bash
# Get default VPC (same as Lab 01)
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)

# Create the new group
WEBSG_ID=$(aws ec2 create-security-group \
  --group-name webserver-sg \
  --description "Web server security group" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" \
  --output text)
echo "webserver-sg ID: $WEBSG_ID"

# SSH — your IP only
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id "$WEBSG_ID" \
  --protocol tcp --port 22 --cidr "$MY_IP/32"

# HTTP — public (Certbot needs this)
aws ec2 authorize-security-group-ingress \
  --group-id "$WEBSG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

# HTTPS — public
aws ec2 authorize-security-group-ingress \
  --group-id "$WEBSG_ID" \
  --protocol tcp --port 443 --cidr 0.0.0.0/0

# Confirm
aws ec2 describe-security-groups \
  --group-ids "$WEBSG_ID" \
  --query "SecurityGroups[].IpPermissions[].{Protocol:IpProtocol,Port:FromPort,CIDR:IpRanges[0].CidrIp}" \
  --output table
```

Expected:
```
-------------------------------------------
|       DescribeSecurityGroups             |
+----------+------+------------------------+
| Protocol | Port |         CIDR           |
+----------+------+------------------------+
|  tcp     |  22  |  X.X.X.X/32           |
|  tcp     |  80  |  0.0.0.0/0            |
|  tcp     |  443 |  0.0.0.0/0            |
+----------+------+------------------------+
```

---

## Task 2 — Replace the Security Group on Your Instance

```bash
# Attach the new security group to devops-lab-server
# Note: --groups replaces ALL security groups on the instance — include every
# group you want active; any group not listed here will be removed.
aws ec2 modify-instance-attribute \
  --instance-id "$INSTANCE_ID" \
  --groups "$WEBSG_ID"

# Confirm the instance now has webserver-sg (not devops-lab-sg)
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].SecurityGroups[].{Name:GroupName,ID:GroupId}" \
  --output table
```

Expected:
```
-----------------------------------------------
|            DescribeInstances                |
+------------------+--------------------------+
|        ID        |          Name            |
+------------------+--------------------------+
|  sg-0abc123      |  webserver-sg            |
+------------------+--------------------------+
```

---

## Task 3 — Test Port Reachability from Your Local Machine

Once SSH is working (next lab), test whether the firewall rules allow traffic on specific ports:

```bash
# On your LOCAL machine — test if port 80 is open on the server
nc -zv YOUR_SERVER_IP 80
```

Expected output (port open):
```
Connection to 54.123.45.67 port 80 [tcp/http] succeeded!
```

Expected output (port blocked):
```
nc: connectx to 54.123.45.67 port 80 (tcp) failed: Connection refused
```

---

## Task 4 — Inspect Security Group Rules

```bash
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=webserver-sg" \
  --query "SecurityGroups[].{Name:GroupName,ID:GroupId,Rules:IpPermissions}" \
  --output json
```

---

## Reflection Questions

1. What happens if you remove the HTTP (port 80) rule while Nginx is running — can you still reach the website?
2. Why is it safer to restrict SSH to "My IP" instead of `0.0.0.0/0`?
3. If your home IP changes (e.g. you reconnect to a different network), what do you need to update?
4. `modify-instance-attribute --groups` replaces all groups at once. What is the risk if you forget to include an existing group in the list?


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
