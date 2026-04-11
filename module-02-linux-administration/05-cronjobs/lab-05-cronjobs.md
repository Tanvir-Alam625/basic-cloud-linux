# Lab 05 — Cronjobs

## Task 1 — Cron Syntax Practice

Before setting up jobs, decode these cron expressions:

| Expression | What does it do? |
|------------|-----------------|
| `0 3 * * *` | Every day at 3:00 AM |
| `*/10 * * * *` | Every 10 minutes |
| `0 9 * * 1` | Every Monday at 9:00 AM |
| `0 0 1 * *` | First day of every month at midnight |
| `30 23 * * 5` | Every Friday at 11:30 PM |
| `0 8-18 * * 1-5` | Every hour from 8 AM to 6 PM, weekdays |

Use [crontab.guru](https://crontab.guru) to verify your understanding.

---

## Task 2 — A Job That Logs Evidence

```bash
# Set up the job
crontab -e
```

Add:
```
* * * * *  date >> /tmp/heartbeat.log
```

Wait 3 minutes:
```bash
tail -f /tmp/heartbeat.log
```

Press `Ctrl+C` when you've seen 3 entries.

```bash
# Clean up
crontab -e  # remove the line
rm /tmp/heartbeat.log
```

---

## Task 3 — A Real Backup Job

```bash
# Create test data to back up
mkdir -p ~/myapp/data
echo "Important data" > ~/myapp/data/records.txt

# Set up a backup cron job (every 5 minutes for testing)
crontab -e
```

Add:
```
*/5 * * * *  tar -czf /tmp/myapp-backup-$(date +\%Y\%m\%d-\%H\%M).tar.gz ~/myapp/data/ 2>/dev/null
```

Wait 5–10 minutes:
```bash
ls -lh /tmp/myapp-backup-*.tar.gz

# Verify the backup is valid
tar -tzf /tmp/myapp-backup-*.tar.gz | head
```

Expected:
```
home/ubuntu/myapp/data/
home/ubuntu/myapp/data/records.txt
```

---

## Task 4 — A Disk Monitoring Job

```bash
# Create a writable logs directory in your home folder.
# Do NOT write to /var/log directly — the ubuntu user has no write access there.
# The cron job will silently fail with no output if you use /var/log.
mkdir -p ~/logs

crontab -e
```

Add:
```
*/2 * * * *  df -h / | tail -1 >> ~/logs/disk-usage.log 2>&1
```

Wait a few minutes:
```bash
cat ~/logs/disk-usage.log
```

Expected:
```
/dev/xvda1      7.6G  2.1G  5.5G  28% /
/dev/xvda1      7.6G  2.1G  5.5G  28% /
```

---

## Task 5 — @reboot Job

```bash
crontab -e
```

Add:
```
@reboot  echo "Server started at $(date)" >> /var/log/boot-events.log
```

To test without rebooting the server, check the format is correct with:
```bash
crontab -l | grep reboot
```

On your next server restart, check:
```bash
cat /var/log/boot-events.log
```

---

## Task 6 — Verify cron Service is Running

```bash
sudo systemctl status cron

# Expected:
# ● cron.service - Regular background program processing daemon
#      Active: active (running)
```


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
