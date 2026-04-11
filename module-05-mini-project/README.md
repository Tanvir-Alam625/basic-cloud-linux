# Module 05 — Mini Project: Deploy a Production-Ready Website

## Overview

This project brings together everything from Modules 01–04. You will deploy a portfolio website on AWS EC2 from scratch: provision the server, configure the firewall, install and configure nginx, map a domain, and secure it with HTTPS.

By completing this project, you'll have gone through the end-to-end workflow that real DevOps engineers perform when setting up a new web server.

---

## What You'll Build

A production-ready web server on AWS that:
- Runs on Ubuntu 22.04 LTS (t2.micro / t3.micro)
- Is secured with UFW firewall
- Serves a static website with Nginx
- Uses a custom domain name
- Has HTTPS with auto-renewing SSL (Let's Encrypt)
- Uses Nginx as a reverse proxy (optional extension)

---

## Architecture

```
Your browser
    │ HTTPS :443 / HTTP :80 → 301 redirect
    ▼
Route 53 — aws-basic.ostaddevops.click
    │ A record
    ▼
Elastic IP (static — survives stop/start)
    │
    ▼
AWS Security Group
    Inbound: :22 (your IP), :80 (0.0.0.0/0), :443 (0.0.0.0/0)
    │
    ▼
EC2 t2.micro — Ubuntu 22.04 LTS
    ├── UFW (OS firewall: 22, 80, 443)
    └── Nginx
          ├── :80 → 301 → https
          └── :443 → /var/www/portfolio/ (SSL via Let’s Encrypt)
```

---

## Project Requirements

### Core Requirements (must complete)

- [ ] EC2 instance launched (Ubuntu 22.04, t2.micro)
- [ ] Elastic IP allocated and associated with the instance
- [ ] Security Group configured (SSH from your IP, HTTP/HTTPS from anywhere)
- [ ] SSH connection working with key pair
- [ ] UFW enabled with correct rules (22, 80, 443)
- [ ] Nginx installed and serving the site
- [ ] Custom HTML website deployed to `/var/www/portfolio/`
- [ ] Nginx server block configured for your domain
- [ ] Route53 A record pointing `aws-basic.ostaddevops.click` to the Elastic IP
- [ ] HTTPS certificate issued and installed via Certbot
- [ ] HTTP → HTTPS redirect working
- [ ] SSL auto-renewal verified with `certbot renew --dry-run`

### Extension Challenges (optional)

- [ ] Set up a cron job that logs disk usage every 6 hours
- [ ] Add the `log-monitor.sh` script from Module 02 as a daily cron job
- [ ] Configure nginx to serve the reverse proxy pattern (app on port 3000)
- [ ] Assign an Elastic IP to the instance
- [ ] Add a `www` redirect (www → root domain)

---

## Resources in This Folder

| File | What It Does |
|------|-------------|
| [SOLUTION.md](./SOLUTION.md) | Complete step-by-step guided walkthrough |
| `scripts/setup-server.sh` | Automated provisioning (UFW, Nginx, tools) |
| `scripts/deploy-app.sh` | Copies the HTML site and configures Nginx |
| `configs/nginx-project.conf` | Production nginx config with all directives explained |
| `html/index.html` | Sample portfolio HTML |
| `html/style.css` | Stylesheet for the portfolio site |

---

## How to Approach This

Try to complete each step on your own first, referring back to the relevant module for guidance. Only consult [SOLUTION.md](./SOLUTION.md) when you are genuinely stuck.

The goal is not to execute commands from a guide — it's to practise thinking through each step and understanding why each command is run.

Start here: [SOLUTION.md](./SOLUTION.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
