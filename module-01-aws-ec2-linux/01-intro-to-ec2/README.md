# 01 — Introduction to AWS EC2

## What is EC2?

Amazon EC2 (Elastic Compute Cloud) is a service that lets you rent virtual servers in the cloud. Instead of buying physical hardware, you spin up a server in minutes, pay for only what you use, and shut it down when you're done.

Think of it like renting an apartment instead of buying a house — you get all the functionality without owning the infrastructure.

---

## Key Concepts

### Instance
An instance is a virtual server. It runs an operating system (like Ubuntu) and behaves exactly like a physical machine — you can SSH into it, install software, run web servers, etc.

### AMI (Amazon Machine Image)
An AMI is a pre-packaged operating system image used to create an instance. Common choices:
- **Ubuntu 22.04 LTS** — most popular for DevOps/web servers
- **Amazon Linux 2023** — AWS's own optimised Linux
- **Windows Server** — for Windows workloads

### Instance Types
Instance types define the CPU and RAM allocated to your server.

| Type | vCPU | RAM | Use Case |
|------|------|-----|----------|
| t2.micro | 1 | 1 GB | Free Tier, learning, small apps |
| t3.micro | 2 | 1 GB | Free Tier (newer gen), small apps |
| t3.small | 2 | 2 GB | Light production |
| t3.medium | 2 | 4 GB | Medium load apps |

> For all labs in this repo, **t2.micro or t3.micro** is sufficient and Free Tier eligible.

### Regions & Availability Zones
AWS operates in **regions** (geographic locations, e.g. `us-east-1`, `ap-southeast-1`) and each region has multiple **Availability Zones** (isolated data centres within that region).

Choose the region closest to your users. For these labs, use any region you prefer — just keep it consistent.

### Elastic IP
By default, your EC2 instance gets a new public IP every time it restarts. An **Elastic IP** is a static public IP you can attach to an instance so the address never changes. Useful when pointing a domain to your server.

### Storage — EBS
EC2 instances use **EBS (Elastic Block Store)** volumes as their disk. The default root volume is 8 GB — enough for these labs.

---

## EC2 Pricing Model

| Model | Description |
|-------|-------------|
| On-Demand | Pay per second/hour, no commitment — best for learning |
| Reserved | 1–3 year commitment, up to 75% cheaper |
| Spot | Unused capacity at steep discount, can be interrupted |
| Free Tier | 750 hours/month of t2.micro or t3.micro for 12 months |

> Always use **On-Demand** and the **Free Tier** for these labs. Make sure to stop or terminate instances when not in use to avoid charges.

---

## The EC2 Lifecycle

```
Launch → Running → Stopped → Terminated
                ↑         ↓
              Start      Stop
```

- **Running** — instance is on, you're being billed
- **Stopped** — instance is off, no compute charge (storage still billed)
- **Terminated** — instance is permanently deleted

---

## Next Step

[02 — Launching an EC2 Instance →](../02-launching-ec2/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
