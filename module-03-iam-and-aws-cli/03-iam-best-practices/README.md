# 03 — IAM Best Practices

## Never Use the Root Account for Daily Work

The root account has unlimited power — it can delete your entire AWS account, view billing, override all permissions. Compromise of the root account is catastrophic.

**What to do:**
1. Create an IAM admin user immediately after creating your AWS account
2. Lock away the root password and access keys
3. Enable MFA on the root account
4. Never create access keys for root

---

## Enable MFA (Multi-Factor Authentication)

MFA requires a second verification step beyond just a password. Even if a password is stolen, the attacker cannot log in without the physical MFA device.

**Set up MFA for root:**
1. Sign in as root → click your account name (top right) → **Security credentials**
2. Under **Multi-factor authentication (MFA)** → **Assign MFA device**
3. Choose **Authenticator app** (free, use Google Authenticator or Authy on your phone)
4. Scan the QR code, enter two consecutive codes to verify

**Set up MFA for IAM users:**
1. IAM → Users → `devops-user-01` → **Security credentials** tab
2. Assigned MFA device → **Assign MFA device**
3. Same process as above

---

## Apply Least Privilege

Only give permissions that are actually needed — nothing more.

| Role | Should Have |
|------|-------------|
| Web server (EC2) | S3 read access to its bucket only |
| CI/CD bot | Deploy permissions to specific services only |
| Junior developer | Read-only EC2, no IAM, no billing |
| Senior DevOps | Most AWS services except billing and root actions |

Example of a too-permissive policy:
```json
"Action": "*",
"Resource": "*"
```

Example of a correctly scoped policy:
```json
"Action": ["s3:GetObject", "s3:PutObject"],
"Resource": "arn:aws:s3:::my-app-uploads/*"
```

---

## Use Groups, Not Individual User Policies

Attach policies to groups, not directly to users. This scales: add a user to the right group and they instantly get the correct access.

**Bad:**
- User A → Policy X, Policy Y
- User B → Policy X, Policy Y
- User C → Policy X, Policy Y

**Good:**
- Group `devops-team` → Policy X, Policy Y
- Users A, B, C → Group `devops-team`

---

## Rotate Access Keys Regularly

Access keys don't expire automatically. Rotate them every 90 days.

```bash
# Create a new key
aws iam create-access-key --user-name devops-user-01

# Update your CLI config with the new key
aws configure

# After confirming the new key works, deactivate the old one
aws iam update-access-key \
  --user-name devops-user-01 \
  --access-key-id AKIAOLD... \
  --status Inactive

# After a grace period, delete the old key
aws iam delete-access-key \
  --user-name devops-user-01 \
  --access-key-id AKIAOLD...
```

---

## Use IAM Roles for EC2 Instances (Not Access Keys)

Never put static access keys on an EC2 instance. Use an IAM role instead.

See [02 — IAM Roles & Policies](../02-iam-roles-policies/README.md) for the full explanation and lab.

---

## Never Commit Credentials to Git

Before you push anything to GitHub:
- Your `.gitignore` must include `.env`, `*.pem`, `*.key`
- Run `grep -r "AKIA" .` to check for accidentally included access key IDs
- Tools like `git-secrets` or `trufflehog` can scan for leaked credentials

---

## Quick Security Checklist

Run this after setting up any AWS account:

- [ ] Root account has MFA enabled
- [ ] No access keys created for root
- [ ] Created an IAM admin user for daily use
- [ ] IAM admin user has MFA enabled
- [ ] All EC2 instances use IAM roles, not hardcoded keys
- [ ] `.gitignore` includes `.env`, `*.pem`, `*.key`
- [ ] Access keys are rotated (or set a calendar reminder)
- [ ] No policies with `Action: *` and `Resource: *` unless absolutely necessary

---

## Next Step

[04 — AWS CLI Setup →](../04-aws-cli-setup/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
