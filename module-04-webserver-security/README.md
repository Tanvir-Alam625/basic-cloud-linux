# Module 04 — Web Server & Security

This module covers everything needed to host a website on your EC2 server: installing and configuring Nginx, setting up a domain name with Route53, enabling HTTPS with a free SSL certificate, and using the reverse proxy pattern for app servers.

## Topics

| # | Topic | What You'll Learn |
|---|-------|-------------------|
| 01 | [Nginx Installation](./01-nginx-installation/README.md) | Install, start, test nginx |
| 02 | [Hosting a Static Website](./02-hosting-static-website/README.md) | Virtual hosts, serve HTML from a domain |
| 03 | [Reverse Proxy](./03-reverse-proxy/README.md) | Proxy requests to an app server |
| 04 | [Route53 & DNS](./04-route53-dns/README.md) | Create hosted zone, A records, CNAME — Console + CLI |
| 05 | [Domain Mapping](./05-domain-mapping/README.md) | Point your domain to your EC2 server |
| 06 | [SSL with Certbot](./06-ssl-certbot/README.md) | Free HTTPS with Let's Encrypt |

## Prerequisites

- Running EC2 instance from Module 01
- UFW configured from Module 02
- AWS CLI v2 configured with an IAM user (from Module 03) — required for Route53 and Security Group CLI tasks in topics 04–06
- A registered domain name (for topics 04–06); you can complete 01–03 without one

## By the End of This Module

You'll have a running web server serving a website over HTTPS at your own domain name — the foundation of every production deployment.


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
