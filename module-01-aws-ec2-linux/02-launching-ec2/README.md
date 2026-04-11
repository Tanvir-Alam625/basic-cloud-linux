# 02 — Launching an EC2 Instance

## What You'll Learn

- How to launch a Ubuntu EC2 instance — via the AWS Console and via the AWS CLI
- How to choose the right AMI and instance type
- How to configure storage and tags
- How to create a Key Pair for SSH access
- How to create and attach a Security Group with the right inbound rules

---

## Concept: What Happens When You Launch an Instance?

When you click "Launch", AWS:
1. Picks a physical host in your chosen Availability Zone
2. Copies the AMI (OS image) to a new EBS volume
3. Attaches a network interface with a public IP
4. Boots the operating system
5. Makes the instance available for SSH within 1–2 minutes

---

## Lab — Launch Your First EC2 Instance

### Step 1 — Sign in to the AWS Console

Go to [https://console.aws.amazon.com](https://console.aws.amazon.com) and sign in.

In the top-right corner, confirm your **region**. For these labs, pick a region close to you (e.g. `ap-southeast-1` for Singapore, `us-east-1` for US East).

---

### Step 2 — Navigate to EC2

In the search bar at the top, type **EC2** and click the service.

Click **"Launch Instance"** (orange button, top right of the Instances page).

---

### Step 3 — Name Your Instance

Under **"Name and tags"**, enter a name:
```
devops-lab-server
```

---

### Step 4 — Choose an AMI

Under **"Application and OS Images"**:
- Click **"Ubuntu"** from the Quick Start options
- Select **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
- Architecture: **64-bit (x86)**

---

### Step 5 — Choose Instance Type

Under **"Instance type"**, select:
```
t2.micro  (Free tier eligible)
```
or `t3.micro` if t2.micro is not available in your region.

---

### Step 6 — Create a Key Pair

Under **"Key pair (login)"**, click **"Create new key pair"**:

| Setting | Value |
|---------|-------|
| Key pair name | `devops-lab-key` |
| Key pair type | RSA |
| Private key file format | `.pem` (Linux/Mac) or `.ppk` (Windows PuTTY) |

Click **"Create key pair"** — the `.pem` file downloads automatically.

> **Important:** This file is downloaded once and cannot be re-downloaded. Store it safely. **Never commit it to Git.**

Move your key to a safe location:
```bash
mkdir -p ~/.ssh
mv ~/Downloads/devops-lab-key.pem ~/.ssh/
chmod 400 ~/.ssh/devops-lab-key.pem
```

---

### Step 7 — Configure Network Settings

Under **"Network settings"**, click **"Edit"**:

| Setting | Value |
|---------|-------|
| VPC | Default VPC |
| Subnet | Any (leave default) |
| Auto-assign public IP | Enable |
| Security group | Create a new security group |
| Security group name | `devops-lab-sg` |
| Description | Security group for DevOps lab server |

Add these inbound rules:

| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | My IP | SSH access |
| HTTP | TCP | 80 | Anywhere (0.0.0.0/0) | Web traffic |
| HTTPS | TCP | 443 | Anywhere (0.0.0.0/0) | Secure web traffic |

> Using **"My IP"** for SSH means only your current IP can SSH in. This is more secure than allowing all IPs.

---

### Step 8 — Configure Storage

Under **"Configure storage"**:
```
1x  8 GiB  gp3  Root volume
```

8 GB is enough for all labs. Leave it as default.

---

### Step 9 — Launch

Review the **Summary** on the right:
- Number of instances: **1**
- AMI: Ubuntu 22.04 LTS
- Instance type: t2.micro
- Key pair: devops-lab-key

Click **"Launch instance"**.

---

### Step 10 — View Your Instance

Click **"View all instances"**. You'll see your instance with the status:

```
Instance State:  ● running
Status checks:   2/2 checks passed  (takes 1–2 minutes)
```

Note your **Public IPv4 address** (e.g. `54.123.45.67`) — you'll need it to SSH in.

---

## Expected Result

Your EC2 Instances list shows:

```
Name                Instance ID    Instance Type   Public IPv4      State
devops-lab-server   i-0abc123def   t2.micro        54.123.45.67     running
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgot to download the `.pem` key | You can't re-download it. Terminate the instance and create a new one with a new key pair. |
| Instance type not Free Tier eligible | Make sure to select `t2.micro` or `t3.micro` |
| Instance stuck in "pending" | Wait 2–3 minutes. If it persists, check the status checks tab. |
| No public IP assigned | Make sure "Auto-assign public IP" was enabled in Step 7 |
| Accidentally set SSH source to 0.0.0.0/0 | Go to your Security Group, edit the inbound rule, change source to "My IP" |

---

## Next Step

[03 — Security Groups & Key Pairs →](../03-security-groups-keypairs/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
