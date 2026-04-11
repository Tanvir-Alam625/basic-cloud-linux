# Lab 04 — Route53 & DNS

## Task 1 — Create a Hosted Zone

**Console:**
1. Go to **Route 53 → Hosted zones → Create hosted zone**
2. Fill in: Domain name = `yourdomain.com`, Type = Public hosted zone
3. Click **Create hosted zone**
4. Note the 4 NS records shown after creation:
```
NS 1: ___________________
NS 2: ___________________
NS 3: ___________________
NS 4: ___________________
```

**CLI:**
```bash
aws route53 create-hosted-zone \
  --name yourdomain.com \
  --caller-reference "$(date +%s)"

# Note the HostedZone.Id from the output (strip /hostedzone/ prefix)
ZONE_ID=$(aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='yourdomain.com.'].Id" \
  --output text | sed 's|/hostedzone/||')
echo "Zone ID: $ZONE_ID"
```

---

## Task 2 — List Hosted Zones

**Console:** Route 53 → **Hosted zones** — your zones are listed with their IDs and record counts.

**CLI:**
```bash
# List all your hosted zones
aws route53 list-hosted-zones --output table

# Get the zone ID for your domain
aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='yourdomain.com.'].{ID:Id,Name:Name}" \
  --output table
```

---

## Task 3 — Create an A Record

**Console:**
1. Route 53 → Hosted zones → click your zone
2. **Create record** → Record type: **A**, Record name: (blank = root domain), Value: your EC2 IP, TTL: 300
3. Click **Create records**

**CLI:**
```bash
# Set your values
ZONE_ID="Z1234567890ABC"      # Your hosted zone ID
DOMAIN="yourdomain.com"
YOUR_IP="54.123.45.67"        # Your EC2 public IP

# Create the A record
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

---

## Task 4 — Verify DNS Resolution

```bash
# Install dnsutils if not present
sudo apt install -y dnsutils

# Query your domain
dig yourdomain.com A +short
# Expected: 54.123.45.67 (your IP)

# Query the www subdomain
dig www.yourdomain.com A +short

# Query using Google's public DNS (bypasses local cache)
dig @8.8.8.8 yourdomain.com A +short

# Check TTL (how long it will be cached)
dig yourdomain.com A | grep -A 1 "ANSWER SECTION"
```

---

## Task 5 — Check Propagation

After updating nameservers, check global propagation:

```bash
# From your server, query multiple public resolvers
for resolver in 8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9; do
  echo -n "Resolver $resolver: "
  dig @$resolver yourdomain.com A +short
done
```

If all return the same IP, propagation is complete.

---

## Task 6 — Allocate and Assign an Elastic IP

**Console:**
1. EC2 → **Elastic IPs** → **Allocate Elastic IP address** → Amazon's pool → **Allocate**
2. Select the new EIP → **Actions** → **Associate Elastic IP address**
3. Resource type: Instance → select your instance → **Associate**

**CLI:**
```bash
# Allocate an Elastic IP
aws ec2 allocate-address --domain vpc

# Note the AllocationId and the PublicIp returned:
# {
#   "PublicIp": "54.xxx.xxx.xxx",
#   "AllocationId": "eipalloc-xxxxxxxxx",
# }

ALLOC_ID="eipalloc-xxxxxxxxx"   # replace with your value

# Get your instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-lab-server" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

# Associate the Elastic IP with your instance
aws ec2 associate-address \
  --instance-id "$INSTANCE_ID" \
  --allocation-id "$ALLOC_ID"

echo "Elastic IP associated. Update your Route53 A record with the new IP."
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
