# Lab 04 — AWS CLI Setup

## Task 1 — Install on EC2 and Verify

```bash
# SSH into your instance
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP

# Install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
rm -rf aws awscliv2.zip
```

Expected: `aws-cli/2.x.x Python/3.x.x Linux/...`

---

## Task 2 — Configure Default Profile

```bash
aws configure
```

Enter:
- Access Key ID: (from IAM user creation)
- Secret Access Key: (from IAM user creation)
- Region: (your region, e.g. `ap-southeast-1`)
- Output: `json`

Verify:
```bash
cat ~/.aws/credentials
cat ~/.aws/config
```

---

## Task 3 — Verify Identity and Run First Commands

```bash
# Who am I?
aws sts get-caller-identity

# List my EC2 instances
aws ec2 describe-instances \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType}" \
  --output table

# What region am I in?
aws configure get region
```

---

## Task 4 — Practice Named Profiles

```bash
# Set up a second profile (use the same keys for now — in real use these would differ)
aws configure --profile lab

# Use the named profile
aws sts get-caller-identity --profile lab

# Switch global default with env var
export AWS_PROFILE=lab
aws sts get-caller-identity   # uses 'lab' profile now

# Reset
unset AWS_PROFILE
aws sts get-caller-identity   # uses default profile again
```

---

## Task 5 — Explore CLI Help

The CLI has built-in documentation for every service and command:

```bash
# List all available services
aws help | head -50

# Get help for a service
aws ec2 help | head -30

# Get help for a specific command
aws ec2 describe-instances help

# See available subcommands for a service
aws iam help | grep "AVAILABLE COMMANDS" -A 50 | head -30
```

---

## Task 6 — Use the CLI to Describe Your Security Group

```bash
# List all security groups
aws ec2 describe-security-groups \
  --query "SecurityGroups[].{Name:GroupName,ID:GroupId}" \
  --output table

# Get the rules for your security group by name
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=devops-lab-sg" \
  --query "SecurityGroups[0].IpPermissions" \
  --output table
```

---

## Task 7 — Verify the Script

Run the verification script from this folder:

```bash
bash scripts/verify-cli.sh
```

Expected: a summary showing CLI version, your identity, and a list of your instances.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
