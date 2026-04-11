# Module 03 — IAM & AWS CLI

This module covers Identity and Access Management (IAM) — the system that controls who can do what in your AWS account — and the AWS CLI, which lets you interact with AWS from the terminal.

## Why This Module Comes Before Web Servers

To use the AWS CLI (covered in topic 04), you need an IAM user with programmatic access and access keys. Understanding IAM first means you know exactly what you're doing when you create those keys — and why security matters.

## Topics

| # | Topic | What You'll Learn |
|---|-------|-------------------|
| 01 | [IAM Users & Groups](./01-iam-users-groups/README.md) | Create users, organise into groups, attach policies |
| 02 | [IAM Roles & Policies](./02-iam-roles-policies/README.md) | Roles for EC2 instances, writing custom policies |
| 03 | [IAM Best Practices](./03-iam-best-practices/README.md) | MFA, least privilege, root account protection |
| 04 | [AWS CLI Setup](./04-aws-cli-setup/README.md) | Install CLI, configure profiles, run your first commands |

## Prerequisites

- An AWS account where you can create IAM users (use your IAM admin user — never use root credentials for day-to-day work)
- Complete [Module 01](../module-01-aws-ec2-linux/README.md) and [Module 02](../module-02-linux-administration/README.md)

## By the End of This Module

You'll understand AWS access control, be able to create IAM users and roles with the right level of access, attach and simulate policies, and operate AWS entirely from the command line using named profiles and `--query` filtering.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
