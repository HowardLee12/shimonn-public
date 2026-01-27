# AWS RDS PostgreSQL Setup Guide

## Step-by-Step Instructions

### 1. Navigate to AWS RDS Console
1. Log in to AWS Console
2. Go to **RDS** service
3. Click **Create database**

### 2. Engine Configuration
- **Engine type**: PostgreSQL
- **Engine Version**: PostgreSQL 15.x (latest stable)
- **Template**: 
  - Select **Free tier** if eligible (first 12 months)
  - Otherwise select **Dev/Test**

### 3. Settings
- **DB instance identifier**: `shimon-db`
- **Master username**: `shimon_admin`
- **Master password**: (Generate a strong password and save it securely)
  - Example: Use AWS Secrets Manager or 1Password
  - **IMPORTANT**: Save this password - you'll need it for DATABASE_URL

### 4. Instance Configuration
- **DB instance class**: `db.t3.micro`
  - 1 vCPU
  - 1 GB RAM
  - ~$15-20/month

### 5. Storage
- **Storage type**: General Purpose SSD (gp3)
- **Allocated storage**: 20 GB
- **Storage autoscaling**: Enable (max 100 GB)

### 6. Connectivity
- **Compute resource**: Don't connect to an EC2 compute resource
- **Network type**: IPv4
- **Virtual private cloud (VPC)**: Default VPC
- **DB Subnet group**: default
- **Public access**: **Yes** (for development; use VPN/bastion for production)
- **VPC security group**: Create new
  - **Security group name**: `shimon-db-sg`
- **Availability Zone**: No preference

### 7. Database Authentication
- **Database authentication**: Password authentication

### 8. Additional Configuration
- **Initial database name**: `shimon` (IMPORTANT: Don't skip this!)
- **DB parameter group**: default.postgres15
- **Backup**:
  - Enable automated backups
  - Backup retention period: 7 days
  - Backup window: No preference
- **Encryption**: Enable encryption (default AWS KMS key)
- **Performance Insights**: Disable (to save cost)
- **Monitoring**: 
  - Enable Enhanced Monitoring: Optional (adds ~$1/month)
  - Granularity: 60 seconds
- **Maintenance**:
  - Enable auto minor version upgrade
  - Maintenance window: No preference

### 9. Create Database
- Review all settings
- **Estimated monthly costs**: ~$15-20/month
- Click **Create database**
- Wait 5-10 minutes for creation

---

## Post-Creation Steps

### 1. Get Database Endpoint
1. Go to RDS Console → Databases
2. Click on `shimon-db`
3. Copy the **Endpoint** (e.g., `shimon-db.xxxxxx.us-east-1.rds.amazonaws.com`)

### 2. Configure Security Group
1. Click on the VPC security group
2. Edit **Inbound rules**
3. Add rule:
   - **Type**: PostgreSQL
   - **Protocol**: TCP
   - **Port**: 5432
   - **Source**: 
     - For development: `My IP` (your current IP)
     - For production: Your EC2 security group or VPN IP range
4. Save rules

### 3. Test Connection (Local)
```bash
# Install PostgreSQL client (if not already installed)
brew install postgresql@15

# Test connection
psql -h shimon-db.xxxxxx.us-east-1.rds.amazonaws.com \
     -U shimon_admin \
     -d shimon

# Enter password when prompted
# If successful, you'll see: shimon=>
```

### 4. Run Schema Migration
```bash
# From your backend directory
psql -h shimon-db.xxxxxx.us-east-1.rds.amazonaws.com \
     -U shimon_admin \
     -d shimon \
     -f schema.sql

# You should see:
# CREATE EXTENSION
# CREATE TABLE
# CREATE INDEX
# ... (multiple times)
```

### 5. Update .env File
```bash
# Update backend/.env with your RDS credentials
DATABASE_URL=postgresql://shimon_admin:YOUR_PASSWORD@shimon-db.xxxxxx.us-east-1.rds.amazonaws.com:5432/shimon
DB_SSL=true
```

### 6. Test Backend Connection
```bash
cd backend
npm install
npm start

# You should see:
# ✅ Connected to PostgreSQL database
# ✅ PostgreSQL connection test successful: 2026-01-21T12:48:54.123Z
```

---

## Cost Optimization Tips

### Free Tier (First 12 Months)
- 750 hours/month of db.t3.micro usage
- 20 GB of General Purpose (SSD) storage
- 20 GB of backup storage

### After Free Tier
- **db.t3.micro**: ~$15/month
- **20 GB gp3 storage**: ~$2.30/month
- **Backup (7 days)**: Free for same size as DB
- **Total**: ~$17-20/month

### To Reduce Costs
1. **Stop instance when not in use** (development only)
   - Stopped instances still incur storage costs
2. **Use Reserved Instances** (1-year commitment, ~40% discount)
3. **Reduce backup retention** (1 day minimum)
4. **Disable Enhanced Monitoring**

---

## Troubleshooting

### Cannot Connect to Database
1. **Check Security Group**: Ensure port 5432 is open to your IP
2. **Check Public Access**: Must be enabled for external connections
3. **Check VPC**: Database must be in a public subnet
4. **Check Password**: Ensure you're using the correct master password

### Connection Timeout
1. **Check Network**: Ensure you're not behind a restrictive firewall
2. **Check AWS Region**: Ensure you're connecting to the correct region
3. **Check Endpoint**: Verify the endpoint URL is correct

### SSL/TLS Errors
1. **Download RDS Certificate**:
   ```bash
   curl -o rds-ca-2019-root.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
   ```
2. **Update connection string**:
   ```
   DATABASE_URL=postgresql://shimon_admin:PASSWORD@endpoint:5432/shimon?sslmode=require
   ```

---

## Next Steps
1. ✅ Create RDS instance
2. ✅ Configure security group
3. ✅ Test connection
4. ✅ Run schema migration
5. ✅ Update .env file
6. ✅ Test backend API
7. 🚀 Deploy to production!
