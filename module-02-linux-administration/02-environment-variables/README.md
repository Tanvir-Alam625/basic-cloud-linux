# 02 — Environment Variables

## What are Environment Variables?

An environment variable is a named value stored in the shell's environment. Programs use them to receive configuration without hard-coding values into source code.

Examples:
- Instead of hard-coding `DB_PASSWORD=abc123` in your app's source code, you set `DB_PASSWORD` as an environment variable and your app reads it at runtime
- The shell itself uses env vars: `PATH` tells it where to find commands, `HOME` is your home directory

---

## Viewing Environment Variables

```bash
# Show all environment variables
printenv

# Show a specific variable
printenv HOME
printenv PATH

# Alternative: echo
echo $HOME
echo $PATH
echo $USER
```

Common pre-set variables:

| Variable | Value | Meaning |
|----------|-------|---------|
| `HOME` | `/home/ubuntu` | Your home directory |
| `USER` | `ubuntu` | Current logged-in user |
| `PATH` | `/usr/local/sbin:/usr/local/bin:...` | Where the shell looks for commands |
| `SHELL` | `/bin/bash` | Which shell you're using |
| `PWD` | `/home/ubuntu` | Current working directory |
| `LANG` | `en_US.UTF-8` | System language/encoding |

---

## Setting Environment Variables

### Temporary (current session only)

```bash
# Set a variable
export APP_PORT=3000
export APP_ENV=development
export DB_HOST=localhost

# Use it
echo "Starting app on port $APP_PORT"
# Output: Starting app on port 3000

# Unset
unset APP_PORT
echo $APP_PORT
# Output: (empty)
```

Variables set with `export` are available to child processes. Without `export`, they're only in the current shell.

```bash
MY_VAR=hello
bash -c 'echo $MY_VAR'        # empty — child process doesn't have it

export MY_VAR=hello
bash -c 'echo $MY_VAR'        # hello — child process inherits it
```

### Persistent — ~/.bashrc and ~/.profile

For variables you want every time you log in:

```bash
nano ~/.bashrc
```

Add at the bottom:
```bash
export APP_ENV=production
export APP_PORT=3000
```

Apply without logging out:
```bash
source ~/.bashrc
```

**~/.bashrc** — runs for interactive non-login shells (most SSH sessions)  
**~/.profile** — runs for login shells  
**~/.bash_profile** — runs for login shells (overrides ~/.profile if it exists)

> For system-wide variables (all users), add to `/etc/environment`.

---

## .env Files

A `.env` file is a plain text file containing environment variable definitions. It's the standard way to store config for applications.

```bash
# Contents of .env
APP_PORT=3000
APP_ENV=production
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=appuser
DB_PASSWORD=MySecurePassword
SECRET_KEY=some-random-secret
```

Loading a `.env` file into the current shell:
```bash
# Method 1: export each line
export $(grep -v '^#' .env | xargs)

# Method 2: source it (simpler but slightly different behaviour)
set -a
source .env
set +a
```

> Never commit `.env` files to Git. Always add `.env` to `.gitignore`.

---

## Lab — Environment Variables

### Step 1 — Explore What's Already Set

```bash
printenv | sort

# Key ones to spot:
echo "Home: $HOME"
echo "User: $USER"
echo "Shell: $SHELL"
echo "Path: $PATH"
```

### Step 2 — Set and Use Variables

```bash
export APP_NAME="MyDevOpsApp"
export APP_PORT=8080
export APP_ENV=staging

# Use them
echo "App '$APP_NAME' will run on port $APP_PORT in $APP_ENV mode"
# Expected: App 'MyDevOpsApp' will run on port 8080 in staging mode

# See them in the environment
printenv | grep APP_
# Expected:
# APP_NAME=MyDevOpsApp
# APP_PORT=8080
# APP_ENV=staging
```

### Step 3 — Persist a Variable

```bash
# Add to .bashrc
echo 'export DEVOPS_HOME="/home/ubuntu/devops-practice"' >> ~/.bashrc

# Apply immediately
source ~/.bashrc

# Verify
echo $DEVOPS_HOME
# Expected: /home/ubuntu/devops-practice

# Verify it survives a new shell session
bash -c 'source ~/.bashrc && echo $DEVOPS_HOME'
```

### Step 4 — Create and Load a .env File

```bash
# Create .env file
cat > ~/app.env << 'EOF'
# Application config
APP_PORT=3000
APP_ENV=production

# Database config
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=appuser
DB_PASSWORD=MySecurePassword

# App secrets
SECRET_KEY=dev-secret-change-in-prod
EOF

# Secure it immediately
chmod 600 ~/app.env

# Load it into the current session
set -a
source ~/app.env
set +a

# Verify
echo "Port: $APP_PORT | Env: $APP_ENV | DB: $DB_HOST:$DB_PORT"
# Expected: Port: 3000 | Env: production | DB: 127.0.0.1:5432
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Variable not available in script | Use `export VAR=value` — not just `VAR=value` |
| Changes to `.bashrc` not taking effect | Run `source ~/.bashrc` or log out and back in |
| Committed `.env` to git by accident | Add `.env` to `.gitignore`. Rotate any exposed secrets immediately. |
| Spaces around `=` in variable assignment | `VAR=value` not `VAR = value` — spaces cause errors |

---

## Next Step

[03 — Logs & Monitoring →](../03-logs-and-monitoring/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
