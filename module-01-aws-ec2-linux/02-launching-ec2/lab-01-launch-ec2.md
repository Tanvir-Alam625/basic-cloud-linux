# Lab 01 — Launch an EC2 Instance

Each task shows both methods — **Console (GUI)** and **CLI**. The end result is identical. You can pick one method per task or do both for the practice.

> **CLI prerequisite:** AWS CLI v2 must be installed and configured.
> If you haven't done that yet, go to [Module 03 — AWS CLI Setup](../../module-03-iam-and-aws-cli/04-aws-cli-setup/README.md) first, then come back.

---

## Task 1 — Create a Key Pair

A key pair is required to SSH into the instance. The private key is generated once — AWS never stores it. If you lose it, you cannot recover it.

### Console

1. EC2 → left sidebar → **Key Pairs** → **Create key pair**
2. Fill in the form:

| Field | Value |
|-------|-------|
| Name | `devops-lab-key` |
| Key pair type | RSA |
| Private key format | `.pem` (Linux / macOS / WSL) |

3. Click **Create key pair** — the `.pem` file downloads immediately
4. Move it and fix permissions:

```bash
mv ~/Downloads/devops-lab-key.pem ~/.ssh/
chmod 400 ~/.ssh/devops-lab-key.pem
```

### CLI

```bash
export AWS_DEFAULT_REGION=ap-southeast-1   # set your region

# Create the pair; --query extracts only the private key text
aws ec2 create-key-pair \
  --key-name devops-lab-key \
  --query "KeyMaterial" \
  --output text > ~/.ssh/devops-lab-key.pem

chmod 400 ~/.ssh/devops-lab-key.pem

# Confirm it was registered
aws ec2 describe-key-pairs \
  --key-names devops-lab-key \
  --query "KeyPairs[].{Name:KeyName,ID:KeyPairId}" \
  --output table
```

---

## Task 2 — Create a Security Group

A Security Group is the firewall that controls what traffic is allowed to reach your instance.

### Console

1. EC2 → left sidebar → **Security Groups** → **Create security group**
2. Fill in the form:

| Field | Value |
|-------|-------|
| Security group name | `devops-lab-sg` |
| Description | DevOps lab security group |
| VPC | Default VPC |

3. Add inbound rules (click **Add rule** for each row):

| Type | Port | Source | Why |
|------|------|--------|-----|
| SSH | 22 | **My IP** | Only your current IP can SSH in |
| HTTP | 80 | **Anywhere (0.0.0.0/0)** | Required for Certbot domain verification |
| HTTPS | 443 | **Anywhere (0.0.0.0/0)** | Secure web traffic |

4. Leave outbound rules as default (All traffic — Anywhere)
5. Click **Create security group**
6. Note the Security group ID shown on the next page (e.g. `sg-0abc123def456`)

> When you choose **My IP**, the Console auto-detects your current public IP. If you switch networks later, the SSH rule will stop working and you'll need to update it.

### CLI

```bash
# Get the default VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)
echo "Default VPC: $VPC_ID"

# Create the group
SG_ID=$(aws ec2 create-security-group \
  --group-name devops-lab-sg \
  --description "DevOps lab security group" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)
echo "Security Group ID: $SG_ID"

# Get your current public IP — restrict SSH to only this address
MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "Your IP: $MY_IP"

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "$MY_IP/32"

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 443 --cidr 0.0.0.0/0

# Confirm all three rules
aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
  --query "SecurityGroups[].IpPermissions[].{Protocol:IpProtocol,Port:FromPort,CIDR:IpRanges[0].CidrIp}" \
  --output table
```

Expected:
```
+----------+------+------------------------+
| Protocol | Port |         CIDR           |
+----------+------+------------------------+
|  tcp     |  22  |  X.X.X.X/32            |
|  tcp     |  80  |  0.0.0.0/0             |
|  tcp     |  443 |  0.0.0.0/0             |
+----------+------+------------------------+
```

---

> **CLI users — variable recovery**
> If you used the **Console** for Tasks 1 or 2, the shell variables `$SG_ID` and `$AMI_ID`
> won't be set. Run these now before continuing with any CLI task:
> ```bash
> # Recover Security Group ID
> SG_ID=$(aws ec2 describe-security-groups \
>   --filters "Name=group-name,Values=devops-lab-sg" \
>   --query "SecurityGroups[0].GroupId" --output text)
> echo "SG_ID=$SG_ID"
>
> # Recover latest Ubuntu 22.04 AMI for your region
> AMI_ID=$(aws ec2 describe-images \
>   --owners 099720109477 \
>   --filters \
>     "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
>     "Name=state,Values=available" \
>     "Name=architecture,Values=x86_64" \
>   --query "sort_by(Images,&CreationDate)[-1].ImageId" \
>   --output text)
> echo "AMI_ID=$AMI_ID"
> ```

---

## Task 3 — Launch the Instance

### Console

1. EC2 → **Instances** → **Launch instances** (orange button)
2. Configure each section:

**Name and tags:**
```
devops-lab-server
```

**Application and OS Images (AMI):**
- Click **Ubuntu** in the Quick Start panel
- Select **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
- Architecture: **64-bit (x86)**

**Instance type:** `t2.micro` (labelled Free Tier eligible)

**Key pair:** Select `devops-lab-key`

**Network settings:**
- Click **Select existing security group**
- Choose `devops-lab-sg`

**Configure storage:** 8 GiB gp3 (default is fine)

3. Check the **Summary** panel on the right — confirm instance type, AMI, and key pair
4. Click **Launch instance**
5. Click the instance ID in the green success banner to open its detail page

### CLI

```bash
# Query the latest official Ubuntu 22.04 AMI for your region.
# Owner 099720109477 is Canonical's (Ubuntu's publisher) official AWS account.
# Always query instead of hardcoding — AMI IDs change per region and with updates.
AMI_ID=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    "Name=state,Values=available" \
    "Name=architecture,Values=x86_64" \
  --query "sort_by(Images,&CreationDate)[-1].ImageId" \
  --output text)
echo "AMI: $AMI_ID"

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name devops-lab-key \
  --security-group-ids "$SG_ID" \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-lab-server}]' \
  --query "Instances[0].InstanceId" \
  --output text)
echo "Launched: $INSTANCE_ID"
```

---

## Task 4 — Wait for Running State and Note Details

### Console

1. EC2 → **Instances** — find `devops-lab-server`
2. Watch the **Instance state** column — refresh until it shows **running** (takes ~30–60 seconds)
3. Watch **Status check** — wait for **2/2 checks passed** (takes ~1–2 minutes)
4. Click the instance name to open the detail panel. Fill in:

```
Instance ID:       ________________________________
Public IPv4:       ___.___.___.___ 
Private IPv4:      ___.___.___.___ 
Availability Zone: ___________________
AMI ID:            ________________________________
```

### CLI

```bash
# wait instance-running polls every 15 seconds and returns when state = running
echo "Waiting for running state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
echo "Ready."

aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[].Instances[].{
    ID:InstanceId,
    State:State.Name,
    PublicIP:PublicIpAddress,
    PrivateIP:PrivateIpAddress,
    AZ:Placement.AvailabilityZone,
    AMI:ImageId
  }" \
  --output table
```

---

## Task 5 — Stop and Start (Observe IP Change)

This demonstrates why Elastic IPs exist.

### Console

1. Select `devops-lab-server` → **Instance state** → **Stop instance** → confirm
2. Wait for state: **stopped**
3. Look at **Public IPv4 address** — it is now blank
4. **Instance state** → **Start instance** → wait for **running**
5. Look at **Public IPv4 address** — it is a different IP than before

> A regular EC2 public IP is a temporary lease from AWS's shared pool. AWS recycles it the moment the instance stops. An **Elastic IP** is a fixed address you own — it stays attached through stop/start cycles. You'll use one in Module 04 when you set up Route 53 DNS.

### CLI

```bash
aws ec2 stop-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"

# Public IP should now return "None"
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text

aws ec2 start-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# New IP — different from the original
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
```

---

## Task 6 — Read the System Log

Shows the Linux kernel boot sequence. Useful when an instance won't start or SSH won't respond — you can diagnose problems without SSH access.

### Console

1. Select your instance
2. **Actions** → **Monitor and troubleshoot** → **Get system log**
3. Scroll to the bottom — look for a line like:

```
Cloud-init v. 23.x.x finished at Sat, 11 Apr 2026 ...
```

### CLI

```bash
aws ec2 get-console-output \
  --instance-id "$INSTANCE_ID" \
  --query "Output" \
  --output text | tail -40
```

---

## Verification Checklist

- [ ] `~/.ssh/devops-lab-key.pem` exists with permissions `400`
- [ ] Security group `devops-lab-sg` has rules: port 22 (My IP), 80 and 443 (Anywhere)
- [ ] Instance `devops-lab-server` is in **running** state
- [ ] Public IP is visible in Console or via `describe-instances`
- [ ] Confirmed: stopping the instance clears the public IP
- [ ] Confirmed: starting again assigns a different IP
- [ ] System log shows Ubuntu boot messages (readable via Console or CLI)

---

## Setup — Pin Your Region

Set your region once so every command below picks it up automatically:

```bash
export AWS_DEFAULT_REGION=ap-southeast-1   # change to your region, e.g. us-east-1
```

---

## Task 1 — Create a Key Pair

A key pair is required to SSH into the instance. The private key is downloaded once — AWS does not store it and you cannot retrieve it again.

```bash
# Create the key pair; --query extracts only the private key text; redirect it to a file
aws ec2 create-key-pair \
  --key-name devops-lab-key \
  --query "KeyMaterial" \
  --output text > ~/.ssh/devops-lab-key.pem

# Restrict permissions — SSH refuses a key file that anyone else can read
chmod 400 ~/.ssh/devops-lab-key.pem

# Confirm the key was registered in AWS
aws ec2 describe-key-pairs \
  --key-names devops-lab-key \
  --query "KeyPairs[].{Name:KeyName,ID:KeyPairId}" \
  --output table
```

Expected:
```
-------------------------------------------
|           DescribeKeyPairs               |
+-----------------------+------------------+
|          ID           |      Name        |
+-----------------------+------------------+
|  key-0abc123def456    |  devops-lab-key  |
+-----------------------+------------------+
```

---

## Task 2 — Create a Security Group

```bash
# Get the ID of your default VPC
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" \
  --output text)
echo "Default VPC: $VPC_ID"

# Create the security group in that VPC
SG_ID=$(aws ec2 create-security-group \
  --group-name devops-lab-sg \
  --description "DevOps lab security group" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" \
  --output text)
echo "Security Group ID: $SG_ID"

# Get your current public IP — this is the only IP allowed to SSH in
MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "Your public IP: $MY_IP"

# Allow SSH only from your IP (not from the whole internet)
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 \
  --cidr "$MY_IP/32"

# Allow HTTP from anywhere (needed for Certbot challenge and plain web)
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS from anywhere
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 443 \
  --cidr 0.0.0.0/0

# Confirm all three rules are in place
aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
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

## Task 3 — Find the Latest Ubuntu 22.04 AMI

AMI IDs differ by region and change over time. Always query instead of hardcoding:

```bash
# --owners 099720109477 is Canonical's official AWS account (Ubuntu's publisher)
# This ensures you only get genuine Ubuntu images, not copies from random accounts
AMI_ID=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    "Name=state,Values=available" \
    "Name=architecture,Values=x86_64" \
  --query "sort_by(Images,&CreationDate)[-1].ImageId" \
  --output text)
echo "Latest Ubuntu 22.04 AMI for $AWS_DEFAULT_REGION: $AMI_ID"
```

---

## Task 4 — Launch the Instance

```bash
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name devops-lab-key \
  --security-group-ids "$SG_ID" \
  --count 1 \
  --tag-specifications \
    'ResourceType=instance,Tags=[{Key=Name,Value=devops-lab-server}]' \
  --query "Instances[0].InstanceId" \
  --output text)
echo "Launched: $INSTANCE_ID"
```

---

## Task 5 — Wait for Running State

`aws ec2 wait` polls every 15 seconds automatically — no need to run describe in a loop:

```bash
echo "Waiting for instance to reach running state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
echo "Instance is running."

# Pull the complete detail summary
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[].Instances[].{
    ID:InstanceId,
    State:State.Name,
    PublicIP:PublicIpAddress,
    PrivateIP:PrivateIpAddress,
    AZ:Placement.AvailabilityZone,
    AMI:ImageId
  }" \
  --output table
```

Fill in your values:
```
Instance ID:       ________________________________
Public IPv4:       ___.___.___.___ 
Private IPv4:      ___.___.___.___ 
Availability Zone: ___________________
AMI ID:            ________________________________
```

---

## Task 6 — Stop and Start (Observe IP Change)

```bash
# Stop the instance
aws ec2 stop-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"
echo "Instance stopped."

# Query the public IP — it should return None now
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
# Expected: None

# Start it again
aws ec2 start-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get the new IP — it will be different from the original
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
```

> The IP changed because a regular EC2 public IP is a temporary lease. An **Elastic IP** is a permanent address you own — covered in Module 04 when you set up DNS.

---

## Task 7 — Read the Instance System Log

Useful when an instance won't respond to SSH — shows the kernel boot messages:

```bash
aws ec2 get-console-output \
  --instance-id "$INSTANCE_ID" \
  --query "Output" \
  --output text | tail -40
```

Expected: Ubuntu boot messages ending with something like `Cloud-init ... finished at ...`

---

## Verification Checklist

- [ ] `~/.ssh/devops-lab-key.pem` exists and permissions are `400`
- [ ] Security group `devops-lab-sg` has rules: 22 (My IP), 80 (0.0.0.0/0), 443 (0.0.0.0/0)
- [ ] Instance `devops-lab-server` is in **running** state
- [ ] Public IP is visible from `aws ec2 describe-instances`
- [ ] Confirmed stopping the instance removes the public IP
- [ ] Starting again assigns a different public IP
- [ ] System log is readable via `aws ec2 get-console-output`


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
