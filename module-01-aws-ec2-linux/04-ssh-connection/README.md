# 04 — SSH Connection

## What is SSH?

SSH (Secure Shell) is a protocol that lets you securely connect to a remote server over the network and run commands as if you were sitting in front of it. All communication is encrypted.

When you SSH into your EC2 instance, you get a **shell prompt** — a text interface where you type commands that execute on the remote machine.

---

## SSH Command Syntax

```bash
ssh -i /path/to/key.pem username@server-ip
```

| Part | Meaning |
|------|---------|
| `ssh` | The SSH client command |
| `-i /path/to/key.pem` | Which private key to use for authentication |
| `username` | The default user on the server |
| `server-ip` | The public IP of your EC2 instance |

### Default Usernames by AMI

| AMI | Default Username |
|-----|-----------------|
| Ubuntu | `ubuntu` |
| Amazon Linux 2 / 2023 | `ec2-user` |
| Debian | `admin` |
| CentOS | `centos` |
| RHEL | `ec2-user` |

For these labs, we use Ubuntu so the username is always `ubuntu`.

---

## Lab — Connect to Your EC2 Instance

### Step 1 — Get Your Instance's Public IP

In EC2 Console → click your instance → note **Public IPv4 address**.

Or with AWS CLI:
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-lab-server" \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text
```

### Step 2 — Verify Key File Permissions

```bash
ls -la ~/.ssh/devops-lab-key.pem
```

Expected:
```
-r--------  1 youruser  staff  1675  devops-lab-key.pem
```

If not, fix it:
```bash
chmod 400 ~/.ssh/devops-lab-key.pem
```

### Step 3 — SSH Into the Instance

Replace `54.123.45.67` with your actual Public IP:

```bash
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@54.123.45.67
```

First time connecting, you'll see:
```
The authenticity of host '54.123.45.67 (54.123.45.67)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

Type `yes` and press Enter.

### Step 4 — Verify You're Connected

You'll see the Ubuntu welcome banner and a prompt:

```
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-1034-aws x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/pro

  System information as of Fri Apr 11 12:00:00 UTC 2026

ubuntu@ip-172-31-xx-xx:~$
```

You're now inside the server. The prompt `ubuntu@ip-172-31-xx-xx:~$` means:
- `ubuntu` — your username
- `ip-172-31-xx-xx` — the server's hostname (its private IP)
- `~` — you're in the home directory
- `$` — you're a regular user (not root)

### Step 5 — Run a Quick Test

```bash
whoami
```
Output: `ubuntu`

```bash
hostname
```
Output: `ip-172-31-xx-xx`

```bash
uptime
```
Output: ` 12:00:01 up 5 min,  1 user,  load average: 0.00, 0.00, 0.00`

### Step 6 — Disconnect

```bash
exit
```

Or press `Ctrl + D`.

---

## Make SSH Easier with a Config File

Instead of typing the full command every time, add the server to your SSH config:

```bash
nano ~/.ssh/config
```

Add:
```
Host devops-lab
    HostName 54.123.45.67
    User ubuntu
    IdentityFile ~/.ssh/devops-lab-key.pem
```

Save and exit (`Ctrl+X`, `Y`, Enter).

Now connect with just:
```bash
ssh devops-lab
```

---

## Common Mistakes

| Error | Cause | Fix |
|-------|-------|-----|
| `WARNING: UNPROTECTED PRIVATE KEY FILE!` | `.pem` file permissions too open | `chmod 400 ~/.ssh/devops-lab-key.pem` |
| `Permission denied (publickey)` | Wrong key, wrong username, or key not on server | Check username is `ubuntu`, check you're using the right `.pem` |
| `Connection timed out` | Security Group blocks port 22 | Add SSH inbound rule in Security Group |
| `Connection refused` | SSH service not running, or wrong IP | Verify instance is running, check public IP |
| `Host key verification failed` | Server IP changed but old host key cached | Run `ssh-keygen -R OLD_IP` then reconnect |

---

## Next Step

[05 — Basic Linux Commands →](../05-basic-linux-commands/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
