# 05 — Cronjobs

## What is Cron?

Cron is a time-based job scheduler built into Linux. It runs commands automatically at scheduled times — without you needing to start them manually.

Real-world uses:
- Renew SSL certificates every 90 days
- Take a database backup at 2 AM every night
- Clean up temp files every week
- Restart a flaky service every hour
- Send a disk usage report every morning

---

## The crontab File

Each user has their own crontab (cron table) — a file listing the jobs for that user.

```bash
# Edit your crontab
crontab -e

# List your current crontab
crontab -l

# Remove your crontab (deletes all your cron jobs)
crontab -r

# Edit another user's crontab (as root)
sudo crontab -u www-data -e
```

The system also has cron directories for jobs that run at fixed intervals:

| Directory | Frequency |
|-----------|-----------|
| `/etc/cron.hourly/` | Every hour |
| `/etc/cron.daily/` | Every day |
| `/etc/cron.weekly/` | Every week |
| `/etc/cron.monthly/` | Every month |

---

## Cron Syntax

Each line in a crontab has this format:

```
*  *  *  *  *   /path/to/command
│  │  │  │  │
│  │  │  │  └── Day of week (0-7, where 0 and 7 = Sunday)
│  │  │  └───── Month (1-12)
│  │  └──────── Day of month (1-31)
│  └─────────── Hour (0-23)
└────────────── Minute (0-59)
```

`*` means "every" for that field.

### Examples

```
# Run at 2:30 AM every day
30 2 * * *  /usr/bin/backup.sh

# Run every 5 minutes
*/5 * * * *  /usr/bin/health-check.sh

# Run at midnight on the 1st of every month
0 0 1 * *  /usr/bin/monthly-report.sh

# Run every Monday at 9 AM
0 9 * * 1  /usr/bin/weekly-task.sh

# Run at 6 AM and 6 PM every day
0 6,18 * * *  /usr/bin/twice-daily.sh

# Run every hour from 9 AM to 5 PM on weekdays
0 9-17 * * 1-5  /usr/bin/business-hours.sh

# Run every 15 minutes
*/15 * * * *  /usr/bin/frequent-task.sh
```

### Special Shorthand

```
@reboot     Run once at startup
@yearly     Run once a year (same as 0 0 1 1 *)
@monthly    Run once a month (same as 0 0 1 * *)
@weekly     Run once a week (same as 0 0 * * 0)
@daily      Run once a day (same as 0 0 * * *)
@hourly     Run once an hour (same as 0 * * * *)
```

---

## Cron Best Practices

### Always use full paths

Cron runs in a minimal environment — it doesn't have your `PATH`. Always use absolute paths:

```
# Wrong
* * * * *  apt update

# Correct
* * * * *  /usr/bin/apt update
```

Check where a command lives: `which apt` → `/usr/bin/apt`

### Redirect output to a log file

By default, cron emails output to the system user. Redirect to a file instead:

```
# Capture all output (stdout + stderr) to a log file
30 2 * * *  /usr/bin/backup.sh >> /var/log/backup.log 2>&1

# Only log errors
30 2 * * *  /usr/bin/backup.sh 2>> /var/log/backup-errors.log

# Suppress all output
*/5 * * * *  /usr/bin/health-check.sh > /dev/null 2>&1
```

---

## Lab — Working with Cron

### Step 1 — Open Your Crontab

```bash
crontab -e
```

If asked to choose an editor, select `nano` (option 1).

### Step 2 — Add a Simple Test Job

Add this line to run every minute:

```
* * * * *  echo "cron is running at $(date)" >> /tmp/cron-test.log
```

Save and exit (`Ctrl+X`, `Y`, Enter).

### Step 3 — Verify the Job is Registered

```bash
crontab -l
```

Expected:
```
* * * * *  echo "cron is running at $(date)" >> /tmp/cron-test.log
```

### Step 4 — Wait and Check Output

Wait 2 minutes, then:

```bash
cat /tmp/cron-test.log
```

Expected:
```
cron is running at Fri Apr 11 12:01:01 UTC 2026
cron is running at Fri Apr 11 12:02:01 UTC 2026
```

### Step 5 — Add Practical Jobs

```bash
crontab -e
```

Add these (in addition to or replacing the test job):

```
# Clean up files older than 7 days from /tmp every night at 1 AM
0 1 * * *  find /tmp -type f -mtime +7 -delete >> /var/log/cleanup.log 2>&1

# Renew SSL certificates twice daily (certbot is idempotent — safe to run often)
0 0,12 * * *  /usr/bin/certbot renew --quiet >> /var/log/certbot-renew.log 2>&1

# Disk usage report every morning at 8 AM
0 8 * * *  df -h >> /var/log/disk-usage.log 2>&1

# Backup nginx config every Sunday at 3 AM
0 3 * * 0  tar -czf /home/ubuntu/nginx-config-backup-$(date +\%Y\%m\%d).tar.gz /etc/nginx/ 2>/dev/null
```

> Note: In crontab, `%` has a special meaning (newline). Escape it as `\%` when used in `date` format strings inside crontab.

### Step 6 — Remove the Test Job

Edit the crontab and delete the `echo "cron is running..."` line.

```bash
crontab -e
# Delete the test line, save and exit

# Clean up the test log
rm /tmp/cron-test.log
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Job doesn't run | Check `crontab -l` to confirm it's saved. Check system cron is running: `systemctl status cron` |
| Job runs but does nothing | Missing full paths. Use `/usr/bin/command` not just `command` |
| `%` in date format breaks the job | Escape it: `date +\%Y-\%m-\%d` in crontab |
| No output to debug | Log to a file: `>> /tmp/job.log 2>&1` then inspect |

---

## Next Step

[06 — Troubleshooting Basics →](../06-troubleshooting-basics/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
