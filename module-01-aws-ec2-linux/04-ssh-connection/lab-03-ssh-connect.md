# Lab 03 — SSH Connection

---

## Connecting to Your Instance — Two Ways

### Option A — EC2 Instance Connect (Console, browser-based)

EC2 Instance Connect is a browser-based terminal built into the AWS Console. It requires no key file, no local SSH client, and works from any browser. AWS injects a temporary one-time key automatically.

**When to use it:** Quick checks when you're on a machine without your `.pem` key, or when your SSH client isn't available.

**Limitations:** Sessions time out after ~60 seconds of inactivity. It does not support port forwarding or SCP. Requires the instance to have the `ec2-instance-connect` package installed (Ubuntu 22.04 includes it by default).

**Steps:**
1. EC2 → **Instances** → select `devops-lab-server`
2. Click **Connect** (top right)
3. Choose the **EC2 Instance Connect** tab
4. Username: `ubuntu` (pre-filled)
5. Click **Connect** — a terminal opens in your browser

You should see the Ubuntu welcome banner and an `ubuntu@ip-172-31-xx-xx:~$` prompt.

---

### Option B — Local SSH with Key File

This is the standard method for real work — full session, no timeout, supports SCP and port forwarding.

```bash
# Replace with your instance's current public IP
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP
```

Expected: Ubuntu welcome banner and `ubuntu@ip-172-31-xx-xx:~$` prompt.

---

## Task 1 — Connect and Explore

Connect with either method above, then run each command and record what you see.

```bash
# Who are you?
whoami

# What machine is this?
hostname

# Full system info — kernel version, architecture
uname -a

# How long has the server been running?
uptime

# What's the date/time on the server?
date

# Where are you in the filesystem?
pwd
```

Expected output for `uname -a`:
```
Linux ip-172-31-xx-xx 5.15.0-1034-aws #38-Ubuntu SMP Mon Apr 10 08:05:38 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

---

## Task 2 — Transfer a File with SCP

SCP (Secure Copy) uses the same SSH mechanism to transfer files. Requires Option B (local SSH).

**From your local machine, send a file to the server:**
```bash
# Create a test file locally
echo "Hello from my laptop" > test.txt

# Copy it to the server
scp -i ~/.ssh/devops-lab-key.pem test.txt ubuntu@YOUR_SERVER_IP:~/test.txt
```

**Verify it arrived on the server:**
```bash
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP "cat ~/test.txt"
```

Expected output:
```
Hello from my laptop
```

**Download a file from the server to your local machine:**
```bash
scp -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP:~/test.txt ./downloaded.txt
cat ./downloaded.txt
```

---

## Task 3 — Set Up SSH Config (Quality of Life)

```bash
# On your local machine
nano ~/.ssh/config
```

Add this block (replace with your actual IP):
```
Host devops-lab
    HostName 54.123.45.67
    User ubuntu
    IdentityFile ~/.ssh/devops-lab-key.pem
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

`ServerAliveInterval` sends a keep-alive signal every 60 seconds so your connection doesn't drop during long periods of inactivity.

Now test:
```bash
ssh devops-lab
```

If it connects, your config is working.

---

## Task 4 — Run a Command Without an Interactive Session

```bash
ssh devops-lab "df -h"
```

Expected output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.6G  1.8G  5.7G  24% /
tmpfs           483M     0  483M   0% /dev/shm
```

This is useful in scripts that run commands on remote servers without opening an interactive shell.

# Who are you?
whoami

# What machine is this?
hostname

# What's the full system info?
uname -a

# How long has the server been running?
uptime

# What's the date/time on the server?
date

# Where are you in the filesystem?
pwd
```

Expected output for `uname -a`:
```
Linux ip-172-31-xx-xx 5.15.0-1034-aws #38-Ubuntu SMP Mon Apr 10 08:05:38 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

---

## Task 2 — Transfer a File with SCP

SCP (Secure Copy) uses the same SSH mechanism to transfer files.

**From your local machine, send a file to the server:**
```bash
# Create a test file locally
echo "Hello from my laptop" > test.txt

# Copy it to the server
scp -i ~/.ssh/devops-lab-key.pem test.txt ubuntu@YOUR_SERVER_IP:~/test.txt
```

**Verify it arrived on the server:**
```bash
ssh -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP "cat ~/test.txt"
```

Expected output:
```
Hello from my laptop
```

**Download a file from the server to your local machine:**
```bash
scp -i ~/.ssh/devops-lab-key.pem ubuntu@YOUR_SERVER_IP:~/test.txt ./downloaded.txt
cat ./downloaded.txt
```

---

## Task 3 — Set Up SSH Config (Quality of Life)

```bash
# On your local machine
nano ~/.ssh/config
```

Add this block (replace with your actual IP):
```
Host devops-lab
    HostName 54.123.45.67
    User ubuntu
    IdentityFile ~/.ssh/devops-lab-key.pem
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

The `ServerAliveInterval` setting sends a keep-alive signal every 60 seconds so your connection doesn't drop during long periods of inactivity.

Now test:
```bash
ssh devops-lab
```

If it connects, your config is working.

---

## Task 4 — Run a Command Without an Interactive Session

You can run a single command on the remote server without opening an interactive shell:

```bash
ssh devops-lab "df -h"
```

Expected output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.6G  1.8G  5.7G  24% /
tmpfs           483M     0  483M   0% /dev/shm
```

This is useful in scripts that need to run commands on remote servers.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
