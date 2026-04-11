# Lab 01 — IAM Users & Groups

## Task 1 — Explore the IAM Dashboard

1. Go to IAM in the AWS Console
2. Note the **Security recommendations** section — it shows if root MFA is enabled
3. Check the **IAM users** count and **User groups** count

---

## Task 2 — Create a Read-Only User

Create a second user with read-only access (simulating a junior team member who can view but not change things).

### Console

**Create the group:**
1. IAM → **User groups** → **Create group**
2. Group name: `readonly-team`
3. Attach permissions policy: search for `ReadOnlyAccess` (AWS managed) → check it
4. Click **Create group**

**Create the user:**
1. IAM → **Users** → **Create user**
2. User name: `readonly-user-01`
3. Enable **AWS Console access** → set a password → uncheck **Require reset**
4. Next → **Add user to group** → select `readonly-team`
5. Review → **Create user**
6. No access keys needed (view-only user)

### CLI

```bash
# Create the group
aws iam create-group --group-name readonly-team

# Find the ARN of the AWS-managed ReadOnlyAccess policy
aws iam list-policies --scope AWS \
  --query "Policies[?PolicyName=='ReadOnlyAccess'].Arn" \
  --output text

# Attach it to the group
aws iam attach-group-policy \
  --group-name readonly-team \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Create the user
aws iam create-user --user-name readonly-user-01

# Add to the group
aws iam add-user-to-group \
  --user-name readonly-user-01 \
  --group-name readonly-team

# Create a Console login profile (password for Console sign-in)
aws iam create-login-profile \
  --user-name readonly-user-01 \
  --password "ChangeMe@2026!" \
  --password-reset-required

# Confirm membership
aws iam get-group --group-name readonly-team \
  --query "Users[].UserName" --output table
```

**Verify the restrictions** — sign in as `readonly-user-01` and confirm:
```
✓ View EC2 instances
✓ View S3 buckets
✗ Launch a new EC2 instance  (should be denied)
✗ Delete an S3 object        (should be denied)
```

---

## Task 3 — Inspect IAM

> **CLI prerequisite:** complete topic 04 (AWS CLI Setup) before running the CLI commands below.

### Console

1. IAM → **Users** — check the users list, click any user to see their groups, policies, and security credentials
2. IAM → **User groups** — click a group to see members and attached policies
3. IAM → **Policies** — search for `devops-team` or browse managed policies; click a policy to open the JSON view
4. Top-right → your account name → **Security credentials** — shows your own access keys and MFA status

### CLI

```bash
# List all IAM users
aws iam list-users --output table

# List all groups
aws iam list-groups --output table

# See what policies are attached to a group
aws iam list-attached-group-policies --group-name devops-team

# See all users in a group
aws iam get-group --group-name devops-team

# Show info about the currently authenticated user
aws iam get-user

# Show what you're currently authenticated as (account ID, ARN, user ID)
aws sts get-caller-identity
```

---

## Task 4 — Create a User via CLI

```bash
# Create user
aws iam create-user --user-name cli-test-user

# Add to group
aws iam add-user-to-group \
  --user-name cli-test-user \
  --group-name devops-team

# Create access keys for this user
aws iam create-access-key --user-name cli-test-user

# List users to confirm
aws iam list-users --query "Users[].{Name:UserName,Created:CreateDate}" --output table
```

**Clean up after testing:**
```bash
# Step 1: remove from group (must happen before user deletion)
aws iam remove-user-from-group \
  --user-name cli-test-user \
  --group-name devops-team

# Step 2: find and delete the access key
# (IAM refuses to delete a user that still has access keys)
KEY_ID=$(aws iam list-access-keys \
  --user-name cli-test-user \
  --query "AccessKeyMetadata[0].AccessKeyId" \
  --output text)
aws iam delete-access-key \
  --user-name cli-test-user \
  --access-key-id "$KEY_ID"

# Step 3: now the user can be deleted
aws iam delete-user --user-name cli-test-user

# Confirm it's gone
aws iam list-users --query "Users[?UserName=='cli-test-user']" --output text
# Expected: (no output)
```

---

## Reflection

1. Why is it bad practice to use the root account for AWS CLI access?
2. If you have 20 engineers and need to revoke one person's access to S3, is it easier to manage permissions per-user or per-group?
3. What's the difference between the Console password and Access Keys?


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
