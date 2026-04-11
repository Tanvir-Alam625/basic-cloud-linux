# 02 — IAM Roles & Policies

## What is an IAM Role?

An IAM Role is like a hat that an AWS service (or user) can wear to gain temporary permissions. Unlike users, roles don't have permanent credentials — they issue temporary security tokens.

**The key difference:**
- IAM User → long-lived credentials (access key stays the same until rotated)
- IAM Role → temporary credentials (issued per session, expire automatically)

### Why Roles for EC2?

If your EC2 instance needs to access S3, you have two options:

**Bad approach — static access keys on the server:**
```bash
# On the EC2 instance
aws configure
# Enter access key ID, secret key...
# These keys are now stored in ~/.aws/credentials
# If the server is compromised, those keys are stolen
```

**Good approach — IAM role attached to the instance:**
```bash
# No credentials needed on the server at all
aws s3 ls  # Just works — the instance uses its role automatically
```

The EC2 instance automatically gets temporary credentials from the **Instance Metadata Service** that rotate every few hours. No secrets stored on disk.

---

## How IAM Policies Work

A policy is a JSON document with this structure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
    }
  ]
}
```

| Field | Meaning |
|-------|---------|
| `Effect` | `Allow` or `Deny` |
| `Action` | Which API operations (e.g. `s3:GetObject`, `ec2:DescribeInstances`) |
| `Resource` | Which specific resource (ARN), or `*` for all |

### Common Action Patterns

```
s3:*                  All S3 operations
s3:GetObject          Download objects from S3
ec2:Describe*         All EC2 read/describe operations (no changes)
iam:*                 Full IAM control
```

---

## Lab — Create an EC2 Instance Role

### Step 1 — Create a Policy

IAM Console → **Policies** → **Create policy** → **JSON** tab

Paste this (EC2 read-only + S3 read-only):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2ReadOnly",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3ReadOnly",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
```

- Name: `DevOpsLabReadOnly`
- Description: Read-only EC2 and S3 access for lab instances

### Step 2 — Create a Role for EC2

IAM Console → **Roles** → **Create role**

| Step | Setting | Value |
|------|---------|-------|
| Trusted entity type | AWS service | EC2 |
| Use case | EC2 | |
| Permissions | Search and attach | `DevOpsLabReadOnly` |
| Role name | `EC2-DevOps-Lab-Role` | |

Click **Create role**.

### Step 3 — Attach the Role to Your EC2 Instance

**Console:**

EC2 Console → select your instance → **Actions** → **Security** → **Modify IAM role**

Select `EC2-DevOps-Lab-Role` → Click **Update IAM role**.

**CLI:**

```bash
# Retrieve the instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-lab-server" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

# When a role is created via the Console, AWS automatically wraps it in an
# instance profile (same name as the role). With CLI you do this manually:
aws iam create-instance-profile \
  --instance-profile-name EC2-DevOps-Lab-Role 2>/dev/null || true

aws iam add-role-to-instance-profile \
  --instance-profile-name EC2-DevOps-Lab-Role \
  --role-name EC2-DevOps-Lab-Role 2>/dev/null || true

# Attach the profile to the instance
aws ec2 associate-iam-instance-profile \
  --instance-id "$INSTANCE_ID" \
  --iam-instance-profile Name=EC2-DevOps-Lab-Role

# Confirm
aws ec2 describe-iam-instance-profile-associations \
  --filters "Name=instance-id,Values=$INSTANCE_ID" \
  --query "IamInstanceProfileAssociations[0].{State:State,Profile:IamInstanceProfile.Arn}" \
  --output table
```

### Step 4 — Test on the Instance

SSH into your instance:

```bash
# No aws configure needed!
aws sts get-caller-identity
```

Expected — instead of showing a user, it shows the role:
```json
{
  "UserId": "AROAIOSFODNN7EXAMPLE:i-0abc123def",
  "Account": "123456789012",
  "Arn": "arn:aws:sts::123456789012:assumed-role/EC2-DevOps-Lab-Role/i-0abc123def"
}
```

```bash
# This works (allowed by the role)
aws ec2 describe-instances --region ap-southeast-1 --output table

# This will fail (not in the policy)
aws s3 mb s3://test-bucket-12345
# Expected: An error occurred (AccessDenied)
```

---

## Understanding the Policy in This Repo

See [policies/ec2-readonly-policy.json](./policies/ec2-readonly-policy.json) for the exact policy from this lab.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Putting access keys on EC2 instead of using a role | Remove the keys, create an IAM role, attach to instance |
| Role attached but `aws` CLI still says "no credentials" | Make sure the AWS CLI is installed on the instance |
| Policy doesn't work | Check the ARN in the policy — mistyped service names silently fail |

---

## Next Step

[03 — IAM Best Practices →](../03-iam-best-practices/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
