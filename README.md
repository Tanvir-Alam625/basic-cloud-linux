# AWS & Linux for DevOps — Beginner to Intermediate

A complete, hands-on laboratory repository for learning production-grade DevOps practices on AWS and Linux. Every topic ships with a concept explanation, step-by-step labs, real AWS CLI commands alongside Console walkthroughs, expected output, and a common-mistakes section.

Work through the modules in order — each one builds directly on the previous.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Repository Map](#repository-map)
4. [Prerequisites](#prerequisites)
5. [Local Bootstrap — Clone and First-Time Setup](#local-bootstrap--clone-and-first-time-setup)
6. [AWS Account Bootstrap](#aws-account-bootstrap)
7. [Learning Path](#learning-path)
8. [Module Index](#module-index)
9. [How to Use This Repo](#how-to-use-this-repo)
10. [Lab Workflow](#lab-workflow)
11. [Automation Scripts](#automation-scripts)
12. [Deployment Runbook — Mini Project](#deployment-runbook--mini-project)
13. [Operational Tasks](#operational-tasks)
14. [Security Model](#security-model)
15. [Reliability Considerations](#reliability-considerations)
16. [Introducing Changes Safely](#introducing-changes-safely)
17. [Dependency Map](#dependency-map)
18. [Troubleshooting Reference](#troubleshooting-reference)
19. [Contributing / Issues](#contributing--issues)

---

## Architecture Overview

The capstone outcome of this repository (Module 05) is a production-ready web server with the following architecture:

```
┌──────────── Your local machine ─────────────┐
│  AWS CLI v2                                 │
│  SSH client + .pem key                      │
└────────────────────┬────────────────────────┘
                     │  SSH :22 (your IP only)
                     ▼
┌──────────── AWS Region ──────────────────────┐
│                                              │
│  Route 53 (Hosted Zone: ostaddevops.click)   │
│    A record: aws-basic.ostaddevops.click     │
│           │ points to Elastic IP             │
│           ▼                                  │
│  Elastic IP (static, survives stop/start)    │
│           │                                  │
│           ▼                                  │
│  Security Group (aws-basic-sg)               │
│    Inbound: :22 (your IP), :80 (0.0.0.0/0)   │
│             :443 (0.0.0.0/0)                 │
│           │                                  │
│           ▼                                  │
│  EC2 t2.micro — Ubuntu 22.04 LTS             │
│    ├── UFW firewall (OS-level)               │
│    ├── Nginx (ports 80 + 443)                │
│    │     ├── Block 1: :80 → 301 → HTTPS      │
│    │     └── Block 2: :443 → /var/www/       │
│    ├── Let's Encrypt cert (via Certbot)      │
│    │     auto-renewed by systemd timer       │
│    └── IAM instance role (no static keys)    │
│                                              │
└──────────────────────────────────────────────┘
```

**Design decisions:**

| Decision | Rationale |
|----------|-----------|
| Elastic IP instead of dynamic public IP | Dynamic IPs change on stop/start, breaking DNS records and Certbot certificate reuse |
| Two-block nginx (port 80 = redirect only) | Keeps SSL logic in one place; matches what Certbot produces; zero downtime if cert changes |
| HTTP-only nginx config deployed before Certbot | Certbot's HTTP-01 challenge requires nginx to be UP on port 80 before certs exist — SSL-referencing configs fail `nginx -t` before the cert files are created |
| UFW + Security Group in tandem | Security-in-depth: Security Groups are AWS network-level, UFW is OS-level; both must be updated together for any port change |
| IAM instance role (no root/admin keys on EC2) | Static AWS credentials on a server are a critical security risk; roles provide short-lived tokens that rotate automatically |
| Certbot `--nginx` plugin | Reads the existing nginx config and patches it automatically; handles HTTP → HTTPS redirect and TLS protocol config |

---

## Technology Stack

| Layer | Technology | Version / Notes |
|-------|-----------|----------------|
| Cloud provider | AWS | Free Tier eligible |
| Compute | Amazon EC2 | t2.micro / t3.micro |
| OS | Ubuntu Server | 22.04 LTS (x86-64) |
| Web server | Nginx | Latest stable (`apt`) |
| TLS certificates | Let's Encrypt via Certbot | `python3-certbot-nginx` plugin |
| DNS | Amazon Route 53 | Public hosted zone |
| Static IP | AWS Elastic IP | VPC-scope |
| OS firewall | UFW (Uncomplicated Firewall) | Ubuntu default |
| Access control | AWS IAM | Users, Groups, Roles, Policies |
| CLI automation | AWS CLI v2 | `aws configure` / named profiles |
| Shell scripting | Bash | `#!/bin/bash`, `set -e` |
| Package manager | apt (APT) | Ubuntu 22.04 |
| Process manager | systemd / systemctl | Nginx, Certbot timer |
| Scheduled tasks | cron + systemd timer | Certbot renewal, log rotation |

---

## Repository Map

```
basic-cloud-linux/
│
├── README.md                          ← You are here
├── .gitignore                         ← Keys, .env, logs, .terraform/ excluded
│
├── module-01-aws-ec2-linux/           ─────────────────────────────────────────
│   ├── README.md                      Module landing page + topic index
│   ├── 01-intro-to-ec2/
│   │   └── README.md                  EC2 concepts: AMI, instance types, regions
│   ├── 02-launching-ec2/
│   │   ├── README.md                  Launch walkthrough
│   │   └── lab-01-launch-ec2.md       Console + CLI: launch, key pair, SG
│   ├── 03-security-groups-keypairs/
│   │   ├── README.md
│   │   └── lab-02-security-groups.md  Inbound/outbound rules, Console + CLI
│   ├── 04-ssh-connection/
│   │   ├── README.md
│   │   ├── lab-03-ssh-connect.md      EC2 Instance Connect (browser) + local SSH
│   │   └── scripts/fix-permissions.sh Fix .pem chmod 400
│   ├── 05-basic-linux-commands/
│   │   ├── README.md
│   │   ├── lab-04-linux-commands.md   Navigation, files, text, search
│   │   └── scripts/commands-cheatsheet.sh
│   ├── 06-package-manager-apt/
│   │   ├── README.md
│   │   ├── lab-05-apt.md              apt update/upgrade/install/remove/autoremove
│   │   └── scripts/install-common-tools.sh
│   └── 07-process-manager-systemctl/
│       ├── README.md
│       ├── lab-06-systemctl.md        start, stop, enable, status, journalctl
│       └── scripts/service-management.sh
│
├── module-02-linux-administration/    ─────────────────────────────────────────
│   ├── README.md
│   ├── 01-file-permissions-ownership/
│   │   ├── README.md
│   │   ├── lab-01-permissions.md      chmod (per-type), chown, umask
│   │   └── scripts/permissions-demo.sh
│   ├── 02-environment-variables/
│   │   ├── README.md
│   │   ├── lab-02-env-vars.md         export, .bashrc, /etc/environment
│   │   └── scripts/env-setup.sh
│   ├── 03-logs-and-monitoring/
│   │   ├── README.md
│   │   ├── lab-03-logs.md             journalctl, tail -f, logrotate
│   │   └── scripts/log-monitor.sh
│   ├── 04-firewall-ufw/
│   │   ├── README.md
│   │   ├── lab-04-ufw.md              UFW rules + matching Security Group changes
│   │   └── scripts/ufw-setup.sh
│   ├── 05-cronjobs/
│   │   ├── README.md
│   │   ├── lab-05-cronjobs.md         crontab syntax, user vs root cron
│   │   └── scripts/cron-examples.sh
│   └── 06-troubleshooting-basics/
│       ├── README.md                  Connectivity checklist, Console + CLI
│       └── lab-06-troubleshooting.md
│
├── module-03-iam-and-aws-cli/         ─────────────────────────────────────────
│   ├── README.md
│   ├── 01-iam-users-groups/
│   │   ├── README.md
│   │   └── lab-01-iam-users.md        Create user/group, Console + CLI, cleanup
│   ├── 02-iam-roles-policies/
│   │   ├── README.md
│   │   ├── lab-02-iam-roles.md        Roles, instance profiles, policy simulator
│   │   └── policies/
│   │       └── ec2-readonly-policy.json
│   ├── 03-iam-best-practices/
│   │   └── README.md                  MFA, least privilege, root account checklist
│   └── 04-aws-cli-setup/
│       ├── README.md
│       ├── lab-04-aws-cli.md          Install, configure, named profiles, --query
│       └── scripts/verify-cli.sh
│
├── module-04-webserver-security/      ─────────────────────────────────────────
│   ├── README.md
│   ├── 01-nginx-installation/
│   │   ├── README.md
│   │   ├── lab-01-install-nginx.md
│   │   └── scripts/install-nginx.sh
│   ├── 02-hosting-static-website/
│   │   ├── README.md
│   │   ├── lab-02-static-site.md
│   │   ├── configs/mysite.conf        Nginx virtual host template
│   │   └── html/index.html
│   ├── 03-reverse-proxy/
│   │   ├── README.md
│   │   ├── lab-03-reverse-proxy.md    proxy_pass, headers, 502 simulation
│   │   └── configs/reverse-proxy.conf
│   ├── 04-route53-dns/
│   │   ├── README.md                  Hosted zone creation, Console + CLI
│   │   └── lab-04-route53.md          A record, CNAME, Elastic IP, dig
│   ├── 05-domain-mapping/
│   │   ├── README.md
│   │   └── lab-05-domain-mapping.md   server_name, www redirect
│   └── 06-ssl-certbot/
│       ├── README.md
│       ├── lab-06-ssl.md              Pre-flight, certbot, SG check, renewal
│       └── scripts/setup-ssl.sh       Automated SSL install (DNS-aware)
│
└── module-05-mini-project/            ─────────────────────────────────────────
    ├── README.md                      Project spec and architecture
    ├── SOLUTION.md                    Manual step-by-step for aws-basic.ostaddevops.click
    ├── scripts/
    │   ├── setup-server.sh            Provision once: apt, UFW, nginx, web root
    │   └── deploy-app.sh              Deploy HTML + HTTP nginx config (pre-SSL)
    ├── configs/
    │   └── nginx-project.conf         Final two-block config (reference — Certbot writes this)
    └── html/
        ├── index.html                 Portfolio HTML
        └── style.css                  Dark-theme stylesheet
```

---

## Prerequisites

### 1. AWS Account

- [Create a Free Tier account](https://aws.amazon.com/free/) if you do not have one
- Enable **MFA** on the root account immediately after creation (IAM → Security credentials)
- Do **not** use root account credentials for CLI access — create an IAM admin user instead (covered in Module 03)

### 2. Local Tooling

| Tool | Minimum version | Install |
|------|----------------|---------|
| AWS CLI v2 | 2.x | [docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| SSH client | any | macOS/Linux: built-in; Windows: OpenSSH in PowerShell, [Git Bash](https://gitforwindows.org/), or [Windows Terminal](https://aka.ms/terminal) |
| Git | 2.x+ | [git-scm.com](https://git-scm.com/) |
| `dig` / `nslookup` | any | Linux/macOS: `sudo apt install dnsutils` / built-in; Windows: built-in `nslookup`, or WSL |
| Text editor | — | Any. VS Code recommended for viewing `.md` files with preview |

### 3. Networking

- You must be able to reach `0.0.0.0/0:443` outbound (Let's Encrypt ACME endpoint)
- SSH key files (`.pem`) must have permissions `400` — the SSH client refuses keys that are too open

---

## Local Bootstrap — Clone and First-Time Setup

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_ORG/basic-cloud-linux.git
cd basic-cloud-linux

# 2. Verify no secrets were accidentally committed
git log --all --full-history -- "*.pem" "*.key" ".env"
# Expected: empty — if anything appears, rotate those credentials immediately

# 3. Nothing to build or install locally.
#    All hands-on work runs on your EC2 instance over SSH.
#    The only local tool to verify is the AWS CLI:
aws --version
# Expected: aws-cli/2.x.x  Python/3.x  ...
```

---

## AWS Account Bootstrap

Complete this once before starting Module 01.

```bash
# 1. Configure the AWS CLI with your IAM credentials
aws configure
# AWS Access Key ID [None]:     <your-key-id>
# AWS Secret Access Key [None]: <your-secret>
# Default region name [None]:   ap-southeast-1     ← or your preferred region
# Default output format [None]: json

# 2. Verify you can reach AWS
aws sts get-caller-identity
# Expected: JSON with your Account ID and IAM ARN

# 3. (Optional) Use a named profile if you have multiple accounts
aws configure --profile devops-lab
# Then prefix every command:  aws --profile devops-lab ec2 describe-instances
```

> **Region note:** All labs use a single region. Pick one and stay consistent. `ap-southeast-1` (Singapore) and `us-east-1` (N. Virginia) are common Free Tier regions with full service coverage.

---

## Learning Path

Each module's outcome is the input to the next:

```
Module 01 — AWS EC2 & Linux Fundamentals
│  Launch an EC2 instance, connect via SSH,
│  learn navigation, apt, and systemctl.
│
▼
Module 02 — Linux Administration
│  Lock down the OS: file permissions, environment
│  variables, log review, UFW firewall, cron schedules.
│
▼
Module 03 — IAM & AWS CLI
│  Control who can do what on AWS. Create IAM users,
│  roles, and policies. Set up the AWS CLI and
│  automate AWS tasks from the terminal.
│
▼
Module 04 — Web Server & Security
│  Install Nginx. Host a static site. Set up DNS with
│  Route 53. Map your domain. Issue a free TLS certificate
│  with Certbot. Understand reverse proxy.
│
▼
Module 05 — Mini Project
   Combine everything: EC2 → UFW → Nginx → Route53 A record
   → Certbot SSL → HTTPS at aws-basic.ostaddevops.click.
```

---

## Module Index

| # | Module | Key Skills |
|---|--------|------------|
| 01 | [AWS EC2 & Linux Fundamentals](./module-01-aws-ec2-linux/README.md) | Launch EC2 (Console + CLI), Security Groups, Key Pairs, EC2 Instance Connect, SSH, Linux navigation, apt, systemctl |
| 02 | [Linux Administration](./module-02-linux-administration/README.md) | `chmod`/`chown` (per file-type), environment variables, `journalctl`, UFW + Security Group in tandem, cron scheduling, connectivity troubleshooting |
| 03 | [IAM & AWS CLI](./module-03-iam-and-aws-cli/README.md) | IAM users + groups (Console + CLI), IAM roles + instance profiles, JSON policies, policy simulator, AWS CLI v2 named profiles, JMESPath `--query` |
| 04 | [Web Server & Security](./module-04-webserver-security/README.md) | Nginx installation, virtual hosts, reverse proxy (`proxy_pass`), Route 53 hosted zones + records (Console + CLI), domain mapping, Certbot SSL, auto-renewal |
| 05 | [Mini Project](./module-05-mini-project/README.md) | Full end-to-end deployment for `aws-basic.ostaddevops.click` |

---

## How to Use This Repo

Every topic folder follows an identical structure:

| File | Purpose |
|------|---------|
| `README.md` | Concept explanation — the *what* and *why*. Read this first. |
| `lab-XX-*.md` | Hands-on exercise — numbered tasks with expected output and common mistakes. |
| `scripts/*.sh` | Automation scripts — runnable directly on the EC2 instance. |
| `configs/` | Reference configuration files (nginx server blocks, IAM policy JSON). |

**Navigation rule:** always read `README.md` before the lab. The lab assumes you have read the concept.

---

## Lab Workflow

Every lab follows this pattern. Knowing the pattern in advance removes friction:

```
1. READ   — the topic README.md (concepts, key files, common pitfalls)
2. SET UP — launch or reuse your EC2 instance; SSH in
3. DO     — follow the numbered Tasks in the lab file
4. VERIFY — every Task has an "Expected:" block; confirm your output matches
5. CLEAN  — some labs have a Task N — Clean Up; run it to reset state
```

**SSH quick-connect:**
```bash
# Set once in your shell session to avoid retyping
export KEY=~/Downloads/aws-basic-key.pem
export EC2=ubuntu@YOUR_ELASTIC_IP

ssh -i "$KEY" "$EC2"
```

**Copy files to EC2 (when running scripts from this repo):**
```bash
# Copy the entire repo to your instance (run once)
scp -i "$KEY" -r ./basic-cloud-linux "$EC2":~/

# Or clone directly on the instance
ssh -i "$KEY" "$EC2" "git clone https://github.com/YOUR_ORG/basic-cloud-linux.git"
```

---

## Automation Scripts

These scripts run **on the EC2 instance**, not on your local machine (except `verify-cli.sh`).

| Script | Where to run | What it does |
|--------|-------------|--------------|
| `module-01-aws-ec2-linux/04-ssh-connection/scripts/fix-permissions.sh` | Local | Runs `chmod 400` on `.pem` files in `~/Downloads` |
| `module-01-aws-ec2-linux/06-package-manager-apt/scripts/install-common-tools.sh` | EC2 | Installs curl, wget, git, jq, htop, unzip |
| `module-01-aws-ec2-linux/07-process-manager-systemctl/scripts/service-management.sh` | EC2 | Demonstrates systemctl start/stop/enable/status |
| `module-02-linux-administration/01-file-permissions-ownership/scripts/permissions-demo.sh` | EC2 | Walks through chmod, chown examples |
| `module-02-linux-administration/04-firewall-ufw/scripts/ufw-setup.sh` | EC2 | Configures UFW with standard rules |
| `module-02-linux-administration/05-cronjobs/scripts/cron-examples.sh` | EC2 | Installs example cron jobs |
| `module-02-linux-administration/03-logs-and-monitoring/scripts/log-monitor.sh` | EC2 | Tails and parses nginx/system logs |
| `module-03-iam-and-aws-cli/04-aws-cli-setup/scripts/verify-cli.sh` | Local or EC2 | Checks AWS CLI install, identity, and region |
| `module-04-webserver-security/01-nginx-installation/scripts/install-nginx.sh` | EC2 | Installs nginx, verifies port 80, enables at boot |
| `module-04-webserver-security/06-ssl-certbot/scripts/setup-ssl.sh` | EC2 (as sudo) | Full SSL install — DNS-checks www before requesting cert |
| `module-05-mini-project/scripts/setup-server.sh` | EC2 | Provisions a fresh instance: apt, UFW, nginx, web root |
| `module-05-mini-project/scripts/deploy-app.sh` | EC2 | Deploys HTML + HTTP-only nginx config (pre-SSL step) |

**All scripts use `set -e`** — they exit immediately on any error rather than silently continuing.

**Line-continuation safety:** bash `\` must be the absolute last character on the line — no trailing spaces or comments. All scripts in this repo follow this rule. If you add to any script, do not write:

```bash
# WRONG — space after \ breaks line continuation
sudo apt install -y \
  curl \    # this comment breaks everything
```

---

## Deployment Runbook — Mini Project

Use this for the Module 05 capstone or any time you need to redeploy from scratch.

**Prerequisites before starting:**
- EC2 instance running Ubuntu 22.04 (t2.micro)
- Elastic IP allocated and associated
- Route 53 A record `aws-basic.ostaddevops.click → ELASTIC_IP` exists
- DNS propagated: `dig aws-basic.ostaddevops.click A +short` returns your Elastic IP
- Port 80 and 443 open in both Security Group and UFW

### Step 1 — Provision the server (run once)

```bash
# On the EC2 instance
cd ~/basic-cloud-linux/module-05-mini-project
bash scripts/setup-server.sh
```

What this does: `apt update && upgrade`, installs nginx + certbot + ufw + tooling, configures UFW, creates `/var/www/portfolio`, enables nginx at boot.

### Step 2 — Deploy the website

```bash
bash scripts/deploy-app.sh aws-basic.ostaddevops.click
```

What this does: copies `html/index.html` + `style.css` to `/var/www/portfolio`, writes an **HTTP-only** nginx config (no SSL references), activates the virtual host, reloads nginx.

Why HTTP-only: Certbot's HTTP-01 challenge requires nginx to serve on port 80 before certs exist. An SSL-referencing config would fail `nginx -t` and prevent Certbot from ever running.

### Step 3 — Issue the SSL certificate

```bash
sudo certbot --nginx -d aws-basic.ostaddevops.click
```

What this does: contacts Let's Encrypt, proves domain ownership via HTTP challenge, downloads the certificate to `/etc/letsencrypt/live/aws-basic.ostaddevops.click/`, patches the nginx config to add the HTTPS block and HTTP → HTTPS redirect, installs a systemd timer for auto-renewal.

### Verification

```bash
# DNS resolves to your Elastic IP
dig aws-basic.ostaddevops.click A +short

# HTTP redirects to HTTPS
curl -I http://aws-basic.ostaddevops.click
# Expected: HTTP/1.1 301  Location: https://aws-basic.ostaddevops.click/

# HTTPS returns 200
curl -I https://aws-basic.ostaddevops.click
# Expected: HTTP/2 200

# Certificate is valid and shows correct domain
sudo certbot certificates
```

### Re-deployment (content update only)

```bash
# Update HTML, then re-run deploy (no certbot needed — certs remain)
bash scripts/deploy-app.sh aws-basic.ostaddevops.click
sudo nginx -t && sudo systemctl reload nginx
```

---

## Operational Tasks

### Check nginx status and logs

```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/portfolio-access.log   # live request log
sudo tail -f /var/log/nginx/portfolio-error.log    # error log
```

### Reload nginx after a config change

```bash
sudo nginx -t                        # validate — never reload without this
sudo systemctl reload nginx          # zero-downtime reload
```

### Check SSL certificate expiry

```bash
sudo certbot certificates
# Shows: domains, expiry date, cert path
```

### Force-test SSL auto-renewal

```bash
sudo certbot renew --dry-run
# Expected: "All simulated renewals succeeded"
```

### View the certbot renewal timer

```bash
sudo systemctl status certbot.timer
sudo systemctl list-timers | grep certbot
```

### Check server disk and memory

```bash
df -h              # disk usage per mount point
free -h            # RAM usage
top                # live CPU + memory
```

### List open ports

```bash
sudo ss -tlnp | grep -E ':22|:80|:443'
```

### Update Security Group (adding a new inbound port)

Always update **both** Security Group and UFW together:

```bash
# Console: EC2 → Security Groups → Inbound rules → Add rule
# CLI:
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0

# Then on the EC2 instance:
sudo ufw allow 8080/tcp
sudo ufw status
```

---

## Security Model

| Control | Implementation | Notes |
|---------|---------------|-------|
| SSH access | Key-pair only (`.pem`); port 22 restricted to your IP in Security Group | Never allow `0.0.0.0/0` on port 22 |
| AWS API access | IAM user with least-privilege policy; no root account credentials in CLI | Enable MFA on both root and IAM admin user |
| EC2 AWS API calls | IAM instance role (no static keys on the server) | Role grants only what the instance needs |
| Network ingress | AWS Security Group (network layer) + UFW (OS layer) | Both must be updated for any port addition or removal |
| TLS | Let's Encrypt cert, 90-day validity, auto-renewed by systemd timer | Certbot verifies twice daily; renews when < 30 days remaining |
| Web root files | `www-data:www-data` ownership, dirs `755`, files `644` | Files must not be executable; use `find -type f -exec chmod 644` |
| Secrets | `.pem`, `.env`, `*.key` in `.gitignore` — never committed | If accidentally committed, rotate credentials immediately |
| Hidden files | nginx `location ~ /\. { deny all; }` blocks `.env`, `.git`, etc. | Returns 403 on any dotfile access |

---

## Reliability Considerations

| Risk | Mitigation |
|------|-----------|
| EC2 public IP changes on stop/start | Elastic IP — static, persists across instance lifecycle |
| SSL certificate expires (90-day validity) | Certbot systemd timer checks twice daily; `certbot renew --dry-run` tests renewal path; cron backup in root's crontab |
| nginx config breaks after edit | Always run `sudo nginx -t` before `systemctl reload nginx`; `set -e` in scripts makes automation fail fast |
| Disk fills up | `df -h` cron at 08:00 daily logs to `~/logs/disk-usage.log`; review weekly |
| Instance stops due to maintenance | Elastic IP + nginx/certbot both set to `systemctl enable` — they restart automatically on boot |
| DNS propagation lag | TTL=300 (5 min) for new records; verify with `dig @8.8.8.8` before running certbot |

---

## Introducing Changes Safely

### Changing nginx configuration

```bash
# 1. Edit the config
sudo nano /etc/nginx/sites-available/portfolio

# 2. Validate — ALWAYS before reload
sudo nginx -t
# If "test failed" — fix the error before proceeding

# 3. Reload (zero downtime — active connections complete normally)
sudo systemctl reload nginx

# 4. Verify the site still works
curl -I https://aws-basic.ostaddevops.click
```

### Adding a new IAM policy

1. Write the policy JSON (use [Module 03 `policies/`](./module-03-iam-and-aws-cli/02-iam-roles-policies/policies/) as a template)
2. Test it in the [IAM Policy Simulator](https://policysim.aws.amazon.com/) before attaching
3. Use `aws iam simulate-principal-policy` for CLI-based simulation (covered in Module 03 lab-02 Task 4)
4. Start with read-only access; escalate only what is actually needed

### Modifying a shell script

- Never add `# inline comments` after a `\` line continuation — it breaks bash completely with no obvious error
- Test with `bash -n scriptname.sh` (syntax check) before running on the instance
- If the script creates resources (UFW rules, files), check idempotency — can it be safely re-run?

### Updating DNS records

- Lower TTL to 300 before you make changes so rollback is fast
- Verify propagation with `dig @8.8.8.8 aws-basic.ostaddevops.click A +short` before running certbot
- Never run `certbot --nginx` until `curl -I http://DOMAIN` returns 200 from the target server

---

## Dependency Map

The modules have strict ordering dependencies:

```
Module 01
  └─ requires: AWS account, SSH client, .pem key
       └─ outputs: running EC2 instance, knows Linux basics

Module 02
  └─ requires: Module 01 EC2 instance
       └─ outputs: UFW configured, cron set up, log reading skill

Module 03
  └─ requires: AWS CLI installed (Module 01 hint: covered in M03 lab)
       └─ outputs: IAM user/role, CLI configured, named profiles

Module 04
  └─ requires: Module 01 (running EC2), Module 02 (UFW), Module 03 (CLI for Route53/SG)
       └─ outputs: Nginx + domain + HTTPS

Module 05
  └─ requires: ALL of Modules 01–04
       └─ outputs: https://aws-basic.ostaddevops.click live
```

**Package dependencies installed by `setup-server.sh`:**

| Package | Purpose |
|---------|---------|
| `nginx` | Web server |
| `certbot` | Let's Encrypt client |
| `python3-certbot-nginx` | Certbot nginx plugin (reads + patches nginx config) |
| `ufw` | OS firewall |
| `curl` | HTTP testing, IP discovery |
| `wget` | File downloads |
| `git` | Clone this repo on the instance |
| `jq` | JSON parsing for AWS CLI output |
| `htop` | Interactive process/resource monitor |
| `dnsutils` | `dig`, `nslookup` for DNS debugging |

---

## Troubleshooting Reference

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `ssh: Permission denied (publickey)` | Wrong key file, wrong user, or key not `chmod 400` | Verify key with `chmod 400 key.pem`; user must be `ubuntu` not `root` or `ec2-user` |
| `ssh: Connection refused` | Port 22 not open in Security Group or UFW | Check Security Group inbound rules; run `sudo ufw status` on instance |
| `curl: (7) Failed to connect` on port 80/443 | Security Group or UFW blocking the port | Add inbound rule in Security Group AND `sudo ufw allow PORT/tcp` |
| nginx shows default page instead of your site | `default` site still enabled | `sudo rm /etc/nginx/sites-enabled/default && sudo systemctl reload nginx` |
| `nginx: [emerg] cannot load certificate` | SSL config deployed before certbot ran | Delete the SSL block, reload nginx, run `setup-server.sh` + `deploy-app.sh` again, then certbot |
| `certbot: Domain control validation failed` | DNS not propagated, port 80 blocked, or wrong domain in A record | Verify `curl -I http://DOMAIN` returns 200 first |
| `certbot: www.subdomain has no A record` | Including `www.sub.domain` in certbot when only `sub.domain` has an A record | Run `certbot --nginx -d sub.domain` only (no www) |
| IAM `delete-user` fails | User has active access keys | `aws iam list-access-keys --user-name NAME` → `delete-access-key` → then `delete-user` |
| Route53 record not resolving | TTL cache, or nameservers not updated at registrar | `dig @8.8.8.8 DOMAIN A +short` bypasses local cache; check registrar NS records match Route53 |
| Cron job not running as expected | Script needs root, but cron is in user's crontab | Use `sudo crontab -e` for jobs that require elevated permissions (e.g., `certbot renew`) |
| `chmod -R 755` made HTML files executable | Wrong: `755` on files sets execute bit | Use `find -type f -exec chmod 644 {} +` for files, `find -type d -exec chmod 755 {} +` for directories |

---

## Contributing / Issues

If you find an error or want to suggest an improvement, open an issue or pull request.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
