# Lab 02 — IAM Roles & Policies

## Task 1 — Read a Policy Document

Open the AWS managed policy `AmazonS3ReadOnlyAccess` and understand it:

```bash
# With CLI (after setup in topic 04):
aws iam get-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --query "Policy.{Name:PolicyName, Description:Description}" \
  --output table

# Get the actual policy document
aws iam get-policy-version \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --version-id v2 \
  --query "PolicyVersion.Document" \
  --output json
```

---

## Task 2 — Create and Attach a Custom Policy

> **Working directory:** the `file://` path below is relative. Run this from the
> `module-03-iam-and-aws-cli/02-iam-roles-policies/` directory, or use an absolute path:
> ```bash
> cd ~/path/to/repo/module-03-iam-and-aws-cli/02-iam-roles-policies
> ```

```bash
# Create the policy from the JSON file in this folder
aws iam create-policy \
  --policy-name DevOpsLabReadOnly \
  --policy-document file://policies/ec2-readonly-policy.json \
  --description "Read-only EC2 and S3 access for lab instances"

# The command output includes the policy ARN — capture it:
POLICY_ARN=$(aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='DevOpsLabReadOnly'].Arn" \
  --output text)
echo "Policy ARN: $POLICY_ARN"

# Attach it to your user group
aws iam attach-group-policy \
  --group-name devops-team \
  --policy-arn "$POLICY_ARN"

# Confirm the policy is attached
aws iam list-attached-group-policies --group-name devops-team --output table
```

---

## Task 3 — Attach the Role to Your EC2 Instance and Verify

### Console

1. EC2 → **Instances** → select your instance (`devops-lab-server`)
2. **Actions** → **Security** → **Modify IAM role**
3. Select `EC2-DevOps-Lab-Role` from the dropdown
4. Click **Update IAM role**
5. Refresh the instance detail page → **Security** tab → confirm **IAM Role** shows `EC2-DevOps-Lab-Role`

### CLI

```bash
# Get the instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-lab-server" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)
echo "Instance: $INSTANCE_ID"

# Get the role ARN
ROLE_ARN=$(aws iam get-role \
  --role-name EC2-DevOps-Lab-Role \
  --query "Role.Arn" \
  --output text)
echo "Role ARN: $ROLE_ARN"

# Attach an instance profile (a role cannot attach to EC2 directly —
# it must be wrapped in an instance profile; AWS creates one automatically
# when you create a role via the Console, but via CLI you must do it explicitly)

# Check if the instance profile already exists
aws iam get-instance-profile \
  --instance-profile-name EC2-DevOps-Lab-Role 2>/dev/null || \
aws iam create-instance-profile \
  --instance-profile-name EC2-DevOps-Lab-Role

# Add the role to the profile (skip if profile already has the role)
aws iam add-role-to-instance-profile \
  --instance-profile-name EC2-DevOps-Lab-Role \
  --role-name EC2-DevOps-Lab-Role 2>/dev/null || true

# Associate the instance profile with the EC2 instance
aws ec2 associate-iam-instance-profile \
  --instance-id "$INSTANCE_ID" \
  --iam-instance-profile Name=EC2-DevOps-Lab-Role

# Confirm the association
aws ec2 describe-iam-instance-profile-associations \
  --filters "Name=instance-id,Values=$INSTANCE_ID" \
  --output table
```

### Verify on the Instance (SSH)

SSH into your instance and test that the role is active — no `aws configure` needed:

```bash
# Verify role identity
aws sts get-caller-identity

# List running instances (allowed by the role)
aws ec2 describe-instances \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name}" \
  --output table

# Try a forbidden action (should fail cleanly with AccessDenied)
aws iam list-users 2>&1 | head -3
# Expected: An error occurred (AccessDenied)
```

---

## Task 4 — Simulate a Policy Decision

Test what a user or role is allowed to do before actually doing it.

### Console

1. IAM → left sidebar → **Policy simulator**
2. Select entity: `devops-user-01`
3. Select service: **S3**
4. Select actions: `GetObject`, `PutObject`
5. Click **Run simulation**
6. Observe: `GetObject` → allowed, `PutObject` → denied (read-only policy)

### CLI

```bash
# Get the user's ARN
USER_ARN=$(aws iam get-user \
  --user-name devops-user-01 \
  --query "User.Arn" --output text)
echo "Simulating for: $USER_ARN"

# Simulate S3 GetObject and PutObject
aws iam simulate-principal-policy \
  --policy-source-arn "$USER_ARN" \
  --action-names "s3:GetObject" "s3:PutObject" \
  --resource-arns "arn:aws:s3:::*" \
  --query "EvaluationResults[].{Action:EvalActionName,Decision:EvalDecision}" \
  --output table
```

Expected:
```
------------------------------------------
|       SimulatePrincipalPolicy          |
+------------------+---------------------+
|      Action      |      Decision       |
+------------------+---------------------+
|  s3:GetObject    |  allowed            |
|  s3:PutObject    |  implicitDeny       |
+------------------+---------------------+
```

You can test any service and action combination this way before making live changes.

---

## Task 5 — Inspect the Instance Metadata for Credentials

On an EC2 instance with a role attached, temporary credentials are available from the instance metadata service:

```bash
# Get the role name
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Get the temporary credentials (replace ROLE_NAME with the output above)
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/EC2-DevOps-Lab-Role | python3 -m json.tool
```

Expected output (values rotate automatically every few hours):
```json
{
  "Code": "Success",
  "LastUpdated": "2026-04-11T12:00:00Z",
  "Type": "AWS-HMAC",
  "AccessKeyId": "ASIAXXX...",
  "SecretAccessKey": "...",
  "Token": "...",
  "Expiration": "2026-04-11T18:00:00Z"
}
```

This is how the AWS CLI on EC2 gets credentials when no `aws configure` has been run.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
