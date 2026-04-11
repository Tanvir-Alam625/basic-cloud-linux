# 04 — AWS CLI Setup

## What is the AWS CLI?

The AWS CLI (Command Line Interface) lets you interact with every AWS service directly from your terminal. Instead of clicking through the Console, you run commands like:

```bash
aws ec2 describe-instances
aws s3 cp file.txt s3://my-bucket/
aws iam create-user --user-name new-user
```

Everything you can do in the AWS Console can be done with the CLI — and it can be automated in scripts.

---

## How the CLI Authenticates

When you run an AWS CLI command, it looks for credentials in this order:

1. **Command line options** — `--profile name`
2. **Environment variables** — `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
3. **AWS config files** — `~/.aws/credentials` and `~/.aws/config`
4. **EC2 Instance metadata** — if running on EC2 with an IAM role (no keys needed)

---

## Installing AWS CLI v2

### On Ubuntu/Debian (your EC2 instance)

```bash
# Download the installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract
unzip awscliv2.zip

# Install
sudo ./aws/install

# Verify
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x Linux/...

# Clean up
rm -rf aws awscliv2.zip
```

### On macOS

```bash
# Option 1: Official installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm AWSCLIV2.pkg

# Option 2: Homebrew
brew install awscli

aws --version
```

### On Windows

Download and run the MSI installer:
```
https://awscli.amazonaws.com/AWSCLIV2.msi
```

Verify in PowerShell:
```powershell
aws --version
```

---

## Configuring the Default Profile

After installing, run:

```bash
aws configure
```

You'll be prompted for:

```
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-southeast-1
Default output format [None]: json
```

| Setting | Recommended Value |
|---------|------------------|
| Access Key ID | From IAM user creation (topic 01) |
| Secret Access Key | From IAM user creation (topic 01) |
| Default region | Closest to you (e.g. `ap-southeast-1` for Singapore) |
| Output format | `json` (or `table` for easier reading) |

This creates two files:

```bash
cat ~/.aws/credentials
# [default]
# aws_access_key_id = AKIAIOSFODNN7EXAMPLE
# aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

cat ~/.aws/config
# [default]
# region = ap-southeast-1
# output = json
```

---

## Named Profiles

You can configure multiple profiles (e.g. dev, staging, production):

```bash
# Configure a named profile
aws configure --profile dev
aws configure --profile prod

# Use a specific profile for a command
aws s3 ls --profile dev

# Set the default profile for the current session
export AWS_PROFILE=dev

# Verify which profile/account you're using
aws sts get-caller-identity
```

Contents of `~/.aws/credentials` with multiple profiles:

```ini
[default]
aws_access_key_id = AKIA...
aws_secret_access_key = ...

[dev]
aws_access_key_id = AKIA...
aws_secret_access_key = ...

[prod]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

---

## Lab — First AWS CLI Commands

### Step 1 — Verify Your Identity

```bash
aws sts get-caller-identity
```

Expected:
```json
{
  "UserId": "AIDAIOSFODNN7EXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/devops-user-01"
}
```

### Step 2 — List Your EC2 Instances

```bash
aws ec2 describe-instances \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table
```

Expected:
```
-------------------------------------------------------
|               DescribeInstances                     |
+-------------+---------+----------------+-------------+
|     ID      |  Name   |      IP        |   State     |
+-------------+---------+----------------+-------------+
| i-0abc123   | devops-lab-server | 54.x.x.x | running |
+-------------+---------+----------------+-------------+
```

### Step 3 — List S3 Buckets

```bash
aws s3 ls
```

Expected (if you have buckets): a list of buckets with dates.
Expected (no buckets): no output (that's fine).

### Step 4 — List IAM Users

```bash
aws iam list-users \
  --query "Users[].{Name:UserName,Created:CreateDate}" \
  --output table
```

### Step 5 — Get Your Account Info

```bash
# Account ID and aliases
aws sts get-caller-identity --query Account --output text

# Available regions
aws ec2 describe-regions \
  --query "Regions[].RegionName" \
  --output table
```

---

## Output Formats

```bash
# JSON (default, machine-readable)
aws ec2 describe-instances --output json

# Table (human readable, great for exploration)
aws ec2 describe-instances --output table

# Text (plain, good for shell scripting)
aws ec2 describe-instances --output text

# YAML
aws ec2 describe-instances --output yaml
```

---

## Filtering with --query

The `--query` option uses JMESPath to extract specific fields from JSON responses:

```bash
# Get just the instance IDs
aws ec2 describe-instances \
  --query "Reservations[].Instances[].InstanceId" \
  --output text

# Get instances that are running
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Unable to locate credentials" | Run `aws configure` or check `~/.aws/credentials` |
| "Invalid client token" | The access key may be deleted or inactive in IAM |
| "AccessDenied" for a valid command | The IAM user doesn't have permission for that action |
| Wrong region — can't see your instances | Add `--region ap-southeast-1` or set it in `aws configure` |
| Secret key shown in history | Avoid passing keys as command args. Use `aws configure` or env vars. |

---

## Next Step

Proceed to [Module 04 — Web Server & Security →](../../module-04-webserver-security/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
