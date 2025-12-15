# Shared Capital Loan System - VPS Deployment Guide

Complete step-by-step guide to deploy this application on your VPS server.

---

## Table of Contents

1. [System Requirements](#1-system-requirements)
2. [Quick Install (One-Click)](#2-quick-install-one-click)
3. [Manual Installation](#3-manual-installation)
4. [Database Setup](#4-database-setup)
5. [Environment Configuration](#5-environment-configuration)
6. [Running the Application](#6-running-the-application)
7. [Production Setup with PM2](#7-production-setup-with-pm2)
8. [Nginx Reverse Proxy](#8-nginx-reverse-proxy)
9. [SSL Certificate (HTTPS)](#9-ssl-certificate-https)
10. [Systemd Service (Alternative)](#10-systemd-service-alternative)
11. [Backup & Maintenance](#11-backup--maintenance)
12. [Troubleshooting](#12-troubleshooting)
13. [Security Recommendations](#13-security-recommendations)

---

## 1. System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+ / Any Linux with Node.js support
- **RAM**: 1GB minimum (2GB recommended)
- **Storage**: 10GB minimum
- **Node.js**: Version 18 or higher
- **PostgreSQL**: Version 13 or higher

### Required Software
- Node.js 18+
- npm 8+
- PostgreSQL 13+
- Git (optional, for cloning)

---

## 2. Quick Install (One-Click)

After extracting the zip file to your VPS:

```bash
# Navigate to project directory
cd shared-capital-system

# Make install script executable
chmod +x deploy/install.sh

# Run the installer
./deploy/install.sh
```

The script will:
1. Check system requirements
2. Install npm dependencies
3. Build the application
4. Guide you through database setup

---

## 3. Manual Installation

### Step 3.1: Install Node.js 20 (if not installed)

**Ubuntu/Debian:**
```bash
# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node -v  # Should show v20.x.x
npm -v   # Should show 10.x.x
```

**CentOS/RHEL:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
```

### Step 3.2: Install PostgreSQL (if not installed)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**CentOS/RHEL:**
```bash
sudo yum install -y postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Step 3.3: Upload and Extract Project

```bash
# Create directory for the app
mkdir -p /var/www
cd /var/www

# Upload your zip file via SCP, SFTP, or wget
# Example with SCP from your local machine:
# scp shared-capital-system.zip user@your-vps-ip:/var/www/

# Extract the zip
unzip shared-capital-system.zip
cd shared-capital-system
```

### Step 3.4: Install Dependencies

```bash
npm install
```

### Step 3.5: Build the Application

```bash
npm run build
```

---

## 4. Database Setup

### Step 4.1: Create PostgreSQL Database and User

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL prompt, run these commands:
```

```sql
-- Create database
CREATE DATABASE shared_capital_db;

-- Create user with password (CHANGE THIS PASSWORD!)
CREATE USER app_user WITH ENCRYPTED PASSWORD 'YourStrongPassword123!';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE shared_capital_db TO app_user;

-- Connect to the database
\c shared_capital_db

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_user;

-- Exit PostgreSQL
\q
```

### Step 4.2: Configure PostgreSQL Authentication

Edit the PostgreSQL authentication file:

```bash
# Find your pg_hba.conf location
sudo -u postgres psql -c "SHOW hba_file;"

# Edit the file (path may vary)
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

Add or modify this line (before other rules):
```
# Allow app_user to connect with password
local   shared_capital_db    app_user                       md5
host    shared_capital_db    app_user    127.0.0.1/32       md5
host    shared_capital_db    app_user    ::1/128            md5
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### Step 4.3: Create Database Tables

**Option A: Using Drizzle (Recommended)**
```bash
npm run db:push
```

**Option B: Manual SQL Import**
```bash
# Run the SQL schema file
sudo -u postgres psql -d shared_capital_db -f deploy/database-schema.sql
```

### Step 4.4: Verify Database Connection

```bash
# Test connection with your credentials
psql -U app_user -d shared_capital_db -h localhost -W
# Enter password when prompted

# List tables
\dt

# You should see: users, share_accounts, loans, etc.
\q
```

---

## 5. Environment Configuration

### Step 5.1: Create Environment File

```bash
cp .env.example .env
nano .env
```

### Step 5.2: Configure Environment Variables

```env
# Database Configuration
DATABASE_URL=postgresql://app_user:YourStrongPassword123!@localhost:5432/shared_capital_db

# JWT Secret - Generate a secure random string!
# Run: openssl rand -base64 64
SESSION_SECRET=paste-your-generated-secret-here

# Server Configuration
NODE_ENV=production
PORT=5000
```

**Generate a secure SESSION_SECRET:**
```bash
openssl rand -base64 64
```

### Step 5.3: Secure the .env File

```bash
chmod 600 .env
```

---

## 6. Running the Application

### Test Run (Development)

```bash
npm run dev
```

### Production Run

```bash
npm run start
```

Access your application at: `http://your-server-ip:5000`

---

## 7. Production Setup with PM2

PM2 keeps your app running and restarts it if it crashes.

### Step 7.1: Install PM2

```bash
sudo npm install -g pm2
```

### Step 7.2: Start Application with PM2

```bash
# Start the application
pm2 start dist/index.cjs --name "shared-capital" --env production

# View status
pm2 status

# View logs
pm2 logs shared-capital

# Save process list for auto-restart on reboot
pm2 save

# Setup startup script (run the command it outputs)
pm2 startup
```

### Step 7.3: PM2 Ecosystem File (Optional)

Create `ecosystem.config.cjs`:

```javascript
module.exports = {
  apps: [{
    name: 'shared-capital',
    script: 'dist/index.cjs',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    }
  }]
};
```

Start with:
```bash
pm2 start ecosystem.config.cjs
```

---

## 8. Nginx Reverse Proxy

### Step 8.1: Install Nginx

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Step 8.2: Configure Nginx

Create site configuration:
```bash
sudo nano /etc/nginx/sites-available/shared-capital
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    # Or use your server IP: server_name 123.45.67.89;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/shared-capital /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 9. SSL Certificate (HTTPS)

### Using Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is set up automatically
# Test renewal:
sudo certbot renew --dry-run
```

---

## 10. Systemd Service (Alternative to PM2)

Create service file:
```bash
sudo nano /etc/systemd/system/shared-capital.service
```

Add:
```ini
[Unit]
Description=Shared Capital Loan System
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/shared-capital-system
ExecStart=/usr/bin/node dist/index.cjs
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=shared-capital
Environment=NODE_ENV=production
Environment=PORT=5000
EnvironmentFile=/var/www/shared-capital-system/.env

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable shared-capital
sudo systemctl start shared-capital

# Check status
sudo systemctl status shared-capital

# View logs
sudo journalctl -u shared-capital -f
```

---

## 11. Backup & Maintenance

### Database Backup

```bash
# Create backup directory
mkdir -p /var/backups/shared-capital

# Backup script
#!/bin/bash
BACKUP_DIR="/var/backups/shared-capital"
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U app_user -h localhost shared_capital_db > "$BACKUP_DIR/backup_$DATE.sql"
# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
```

Add to crontab for daily backups:
```bash
crontab -e
# Add: 0 2 * * * /path/to/backup-script.sh
```

### Database Restore

```bash
psql -U app_user -d shared_capital_db -h localhost < backup_file.sql
```

### Application Updates

```bash
# Stop the app
pm2 stop shared-capital

# Pull updates (if using git)
git pull

# Install dependencies
npm install

# Rebuild
npm run build

# Apply database changes
npm run db:push

# Restart
pm2 restart shared-capital
```

---

## 12. Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Find what's using port 5000
sudo lsof -i :5000
# Kill if needed
sudo kill -9 <PID>
```

**Database connection failed:**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check your DATABASE_URL format
# postgresql://user:password@host:port/database

# Test connection
psql -U app_user -d shared_capital_db -h localhost
```

**Permission denied:**
```bash
# Fix file permissions
sudo chown -R $USER:$USER /var/www/shared-capital-system
chmod -R 755 /var/www/shared-capital-system
chmod 600 .env
```

**Build fails:**
```bash
# Clear npm cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
npm run build
```

**View logs:**
```bash
# PM2 logs
pm2 logs shared-capital

# Systemd logs
sudo journalctl -u shared-capital -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

---

## 13. Security Recommendations

1. **Firewall Configuration:**
   ```bash
   sudo ufw allow 22    # SSH
   sudo ufw allow 80    # HTTP
   sudo ufw allow 443   # HTTPS
   sudo ufw enable
   ```

2. **Keep Software Updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Secure PostgreSQL:**
   - Use strong passwords
   - Restrict connections to localhost only
   - Regular backups

4. **Environment Variables:**
   - Never commit .env to version control
   - Use strong SESSION_SECRET
   - Restrict .env file permissions

5. **Regular Backups:**
   - Automated daily database backups
   - Store backups off-server

---

## Quick Reference Commands

```bash
# Start application
pm2 start shared-capital

# Stop application
pm2 stop shared-capital

# Restart application
pm2 restart shared-capital

# View logs
pm2 logs shared-capital

# Check status
pm2 status

# Database backup
pg_dump -U app_user shared_capital_db > backup.sql

# Check disk space
df -h

# Check memory
free -m
```

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review application logs: `pm2 logs shared-capital`
3. Check database connectivity
4. Verify environment configuration

---

**Application Details:**
- Default Port: 5000
- Default Admin: Create first user, then manually set role to 'admin' in database:
  ```sql
  UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com';
  ```
