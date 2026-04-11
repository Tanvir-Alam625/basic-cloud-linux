# 01 — IAM Users & Groups

## What is IAM?

IAM (Identity and Access Management) is the AWS service that controls authentication and authorisation:

- **Authentication** — who are you? (identity: users, roles)
- **Authorisation** — what are you allowed to do? (policies)

Every API call to AWS — from the Console, CLI, or SDK — is checked against IAM.

---

## Key IAM Concepts

### Root Account
The email/password you used to create your AWS account. Has unlimited access to everything.

> **Never use the root account for daily work.** Create an IAM admin user for everything else.

### IAM User
A named identity that can interact with AWS. Has:
- A login for the AWS Console (username + password)
- Access keys for CLI/API access (Key ID + Secret)
- Policies attached that define what they can do

### IAM Group
A collection of users. Attach policies to the group — all users in the group inherit those permissions. Easier to manage than attaching policies to each user individually.

### IAM Policy
A JSON document that defines permissions. Example: "allow read-only access to all S3 buckets".

### IAM Role
Like a user, but meant to be assumed by services (EC2 instances, Lambda functions) or other AWS accounts — not humans. Covered in detail in the next topic.

---

## Managed vs Inline Policies

| Type | Description | Use When |
|------|-------------|----------|
| AWS Managed | Pre-written by AWS (e.g. `AmazonS3ReadOnlyAccess`) | Common use cases |
| Customer Managed | You write it, reusable across multiple users/groups | Custom permissions |
| Inline | Attached directly to one user/group, not reusable | Strict one-off permissions |

---

## Lab — Create an IAM User

### Step 1 — Navigate to IAM

AWS Console → search "IAM" → click IAM.

### Step 2 — Create a Group First

Go to **User groups** → **Create group**

| Field | Value |
|-------|-------|
| Group name | `devops-team` |
| Attach policies | Search for and check: `AdministratorAccess` |

Click **Create group**.

> In a real environment, you wouldn't give a team AdministratorAccess. You'd use more restrictive policies. For these labs, it simplifies setup.

### Step 3 — Create a User

Go to **Users** → **Create user**

| Step | Setting | Value |
|------|---------|-------|
| Step 1 | User name | `devops-user-01` |
| Step 1 | AWS Console access | ✓ Enable |
| Step 1 | Console password | Custom password (set a strong one) |
| Step 1 | Require password reset | Uncheck for lab use |
| Step 2 | Permissions | Add user to group → `devops-team` |

Review and click **Create user**.

Download or note the sign-in link and password shown.

### Step 4 — Create Access Keys (for CLI)

After the user is created, click on `devops-user-01` → **Security credentials** tab → **Create access key**

| Field | Value |
|-------|-------|
| Use case | Command Line Interface (CLI) |
| Description | DevOps lab CLI key |

Click **Create access key**.

**This is the ONLY time you can see the Secret Access Key. Download the CSV or copy both values now.**

```
Access Key ID:     AKIAIOSFODNN7EXAMPLE
Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

---

## Step 5 — Test Console Login

1. Sign out of the root account (or use a private browser window)
2. Go to the IAM sign-in link shown after user creation:
   `https://YOUR_ACCOUNT_ID.signin.aws.amazon.com/console`
3. Sign in as `devops-user-01` with the password you set
4. Verify you can navigate EC2, IAM, etc.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgot to download access keys | Deactivate the key and create a new one in the Security Credentials tab |
| User can't access a service | Check the attached policies — they must allow that service |
| Giving every user AdministratorAccess | Use least privilege — only grant what's needed (see best practices topic) |

---

## Next Step

[02 — IAM Roles & Policies →](../02-iam-roles-policies/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
