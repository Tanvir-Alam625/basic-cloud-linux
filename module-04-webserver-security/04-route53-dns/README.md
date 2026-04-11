# 04 — Route53 & DNS

## What is DNS?

DNS (Domain Name System) is the phonebook of the internet. It translates human-readable domain names (`yourdomain.com`) into IP addresses (`54.123.45.67`) that computers use.

When you type `yourdomain.com` in a browser:
1. Browser asks a DNS resolver: "what's the IP for yourdomain.com?"
2. Resolver checks the authoritative DNS for that domain
3. Returns the IP address
4. Browser connects to that IP

---

## What is Route53?

Amazon Route53 is AWS's DNS service. It lets you:
- Register domain names
- Host DNS zones for domains you own
- Create DNS records (A, CNAME, MX, TXT, etc.)
- Route traffic with health checks and geolocation

---

## Key DNS Record Types

| Record | Purpose | Example |
|--------|---------|---------|
| A | Maps domain to IPv4 address | `yourdomain.com → 54.123.45.67` |
| AAAA | Maps domain to IPv6 address | `yourdomain.com → 2001:db8::1` |
| CNAME | Alias one name to another | `www → yourdomain.com` |
| MX | Mail server for the domain | `→ mail.yourdomain.com` |
| TXT | Text data (domain verification, SPF records) | `"v=spf1 ..."` |
| NS | Nameservers for the domain | which DNS servers are authoritative |
| SOA | Start of Authority — admin info about the zone | auto-created |

---

## What is TTL?

TTL (Time To Live) tells DNS resolvers how long to cache a record (in seconds). After this time, they must re-check.

| TTL Value | Meaning |
|-----------|---------|
| 60 | Cache for 1 minute — fast propagation, more DNS queries |
| 300 | Cache for 5 minutes — good for active changes |
| 3600 | Cache for 1 hour — balanced |
| 86400 | Cache for 24 hours — stable, fewer queries |

> When setting up a new domain or making changes, use a low TTL (300) first. Once stable, increase it.

---

## Lab — Set Up Route53

### Prerequisites

- A registered domain name (from Route53, Namecheap, GoDaddy, etc.)
- Your EC2 instance's public IP

> If you don't have a domain yet, you can buy one in AWS: Route53 → **Registered domains** → **Register domain**. `.com` domains cost ~$12/year. `.link` or `.click` domains are often cheaper.

### Step 1 — Create a Hosted Zone

**Console:** Route53 → **Hosted zones** → **Create hosted zone**

| Field | Value |
|-------|-------|
| Domain name | `yourdomain.com` |
| Type | Public hosted zone |

Click **Create hosted zone**.

**CLI:**
```bash
aws route53 create-hosted-zone \
  --name yourdomain.com \
  --caller-reference "$(date +%s)" \
  --hosted-zone-config Comment="My public hosted zone"

# The output includes the hosted zone ID and the 4 NS records
# Note the Id: e.g. /hostedzone/Z1234567890ABC  → strip the prefix, use just Z1234567890ABC
```

### Step 2 — Note the Nameservers

After creation, you'll see 4 NS records:

```
ns-xxxx.awsdns-xx.com.
ns-xxxx.awsdns-xx.net.
ns-xxxx.awsdns-xx.org.
ns-xxxx.awsdns-xx.co.uk.
```

These are your authoritative nameservers. You must update your domain registrar to use these.

### Step 3 — Update Nameservers at Your Registrar

Go to wherever you registered your domain (Route53, Namecheap, GoDaddy, etc.) and update the nameservers to match the 4 NS values from Step 2.

This change propagates across the internet — it can take up to 48 hours but usually takes 1–2 hours.

### Step 4 — Create an A Record

**Console:** Back in Route53, in your hosted zone → **Create record**

| Field | Value |
|-------|-------|
| Record name | (leave blank — this is the root domain) |
| Record type | A |
| Value | Your EC2 instance's public IP (e.g. `54.123.45.67`) |
| TTL | 300 |

Click **Create records**.

**CLI:**
```bash
ZONE_ID="Z1234567890ABC"   # your hosted zone ID (without /hostedzone/ prefix)
DOMAIN="yourdomain.com"
YOUR_IP="54.123.45.67"

aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'"$DOMAIN"'",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "'"$YOUR_IP"'"}]
      }
    }]
  }'
```

### Step 5 — Create a www CNAME Record

**Console:** **Create record**

| Field | Value |
|-------|-------|
| Record name | `www` |
| Record type | CNAME |
| Value | `yourdomain.com` |
| TTL | 300 |

Click **Create records**.

**CLI:**
```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "www.'"$DOMAIN"'",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{"Value": "'"$DOMAIN"'"}]
      }
    }]
  }'
```

---

## Step 6 — Verify DNS Propagation

```bash
# Check if your domain resolves (may take a few minutes to hours)
nslookup yourdomain.com
# Expected: shows your EC2 IP

dig yourdomain.com A
# Expected output includes:
# yourdomain.com.  300  IN  A  54.123.45.67

# Check from a public DNS resolver
dig @8.8.8.8 yourdomain.com A

# Simple test
ping yourdomain.com
```

Online tools:
- [dnschecker.org](https://dnschecker.org) — check propagation from multiple regions worldwide

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| DNS not resolving after 30 minutes | Check nameservers at your registrar match Route53's NS records exactly |
| Wrong nameservers | Copy from Route53 hosted zone NS record — include the trailing dot |
| A record points to old IP | EC2 IP changed after restart. Update the A record or use an Elastic IP |
| Visited site but sees old content | DNS is cached — wait for TTL to expire, or flush local DNS cache |

---

## Elastic IP (avoiding IP changes)

If your EC2 instance restarts, its public IP changes. To avoid updating your DNS A record every time:

1. EC2 Console → **Elastic IPs** → **Allocate Elastic IP address**
2. Select the new Elastic IP → **Actions** → **Associate Elastic IP address**
3. Select your instance → **Associate**
4. Update your Route53 A record with the Elastic IP

The Elastic IP stays the same even if the instance restarts.

> Elastic IPs are **free** when associated with a running instance. You're charged ~$0.005/hour when allocated but NOT associated — release them when not in use.

---

## Next Step

[05 — Domain Mapping →](../05-domain-mapping/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
