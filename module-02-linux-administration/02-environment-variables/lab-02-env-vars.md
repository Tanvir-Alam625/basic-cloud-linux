# Lab 02 — Environment Variables

## Task 1 — Explore the Current Environment

```bash
# See all variables, sorted
printenv | sort | head -30

# Count how many environment variables are set
printenv | wc -l

# Show PATH broken into individual entries
echo $PATH | tr ':' '\n'
```

---

## Task 2 — Variable Scope

```bash
# Set WITHOUT export
MY_LOCAL=hello
echo $MY_LOCAL
# Expected: hello (works in this shell)

# Check if child process can see it
bash -c 'echo "Child sees: $MY_LOCAL"'
# Expected: Child sees:   (nothing — not exported)

# Now export it
export MY_LOCAL
bash -c 'echo "Child sees: $MY_LOCAL"'
# Expected: Child sees: hello
```

---

## Task 3 — Build a Working .env File

```bash
# Create a proper .env that simulates an app's config
mkdir -p ~/myapp
cat > ~/myapp/.env << 'EOF'
# Server config
SERVER_HOST=0.0.0.0
SERVER_PORT=3000

# Database
DB_ENGINE=postgresql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=myapp_db
DB_USER=myapp_user
DB_PASSWORD=ChangeMeInProduction!

# Security
JWT_SECRET=please-change-this-to-a-random-string
SESSION_TIMEOUT=3600

# Feature flags
ENABLE_DEBUG=false
ENABLE_LOGGING=true
EOF

chmod 600 ~/myapp/.env

# Load and verify
set -a; source ~/myapp/.env; set +a

echo "Server: $SERVER_HOST:$SERVER_PORT"
echo "Database: $DB_ENGINE://$DB_HOST:$DB_PORT/$DB_NAME"
echo "Debug mode: $ENABLE_DEBUG"
```

---

## Task 4 — System-Wide Environment

```bash
# View system-wide env variables
cat /etc/environment

# Add a custom system-wide variable (requires sudo)
echo 'DEVOPS_ENV=lab' | sudo tee -a /etc/environment

# Verify (takes effect on next login)
cat /etc/environment | grep DEVOPS_ENV
```

---

## Task 5 — Variable Substitution in Practice

```bash
# Variables can reference other variables
export BASE_DIR="/var/www"
export APP_NAME="mysite"
export APP_DIR="$BASE_DIR/$APP_NAME"

echo $APP_DIR
# Expected: /var/www/mysite

# Default values: use fallback if variable is unset
echo ${UNDEFINED_VAR:-"default_value"}
# Expected: default_value

echo ${APP_PORT:-3000}
# Expected: 3000 (if APP_PORT is unset) OR the actual value
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
