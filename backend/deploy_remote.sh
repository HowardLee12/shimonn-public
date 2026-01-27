#!/bin/bash

# Configuration
PEM_KEY="/Users/howardlee.superinsight/Downloads/shimonn.pem"
EC2_HOST="ec2-user@ec2-13-114-217-251.ap-northeast-1.compute.amazonaws.com"
REMOTE_DIR="/home/ec2-user/app/backend"

echo "🚀 Starting Remote Deployment to EC2..."

# 1. Set permissions for PEM key
echo "🔐 Setting permissions for PEM key..."
chmod 400 "$PEM_KEY"

# 2. Create a deployment package
echo "📦 Creating application archive..."

# Temporarily use production env
if [ -f "shimonn.env" ]; then
    echo "⚠️  Using shimonn.env for production deployment..."
    cp .env .env.bak
    cp shimonn.env .env
else
    echo "❌ shimonn.env not found! Cannot deploy without production config."
    exit 1
fi

# Exclude node_modules, .git, and other unnecessary files
tar -czf backend_deploy.tar.gz \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='backend_deploy.tar.gz' \
    --exclude='.env.bak' \
    .

# Restore local env
mv .env.bak .env
echo "✅ Restored local .env"

# 3. Upload to EC2
echo "cF📤 Uploading to EC2..."
scp -i "$PEM_KEY" -o StrictHostKeyChecking=no backend_deploy.tar.gz "$EC2_HOST:/home/ec2-user/"

# 4. Execute remote commands
echo "🔧 Executing remote build and restart..."
ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'EOF'
    # Stop any container using port 3000
    echo "🛑 Stopping any container on port 3000..."
    CONTAINER_ID=$(docker ps -q --filter "publish=3000")
    if [ ! -z "$CONTAINER_ID" ]; then
        docker stop $CONTAINER_ID
        docker rm $CONTAINER_ID
        echo "✅ Stopped container $CONTAINER_ID"
    fi
    
    # Also try to stop by name just in case
    docker stop backend || true
    docker rm backend || true

    # Prepare directory
    mkdir -p /home/ec2-user/app/backend
    
    # Extract new code
    echo "📂 Extracting code..."
    tar -xzf /home/ec2-user/backend_deploy.tar.gz -C /home/ec2-user/app/backend
    
    # Build Docker image
    echo "🏗️ Building Docker image..."
    cd /home/ec2-user/app/backend
    docker build -t shimmon-backend .

    # Run new container
    echo "▶️ Starting new backend container..."
    # Note: Using restart=always to ensure it comes back up
    docker run -d \
        --name backend \
        --restart always \
        -p 3000:3000 \
        --env-file .env \
        shimmon-backend

    # Cleanup
    rm /home/ec2-user/backend_deploy.tar.gz
    
    echo "✅ Remote deployment commands completed!"
EOF

# 5. Cleanup local archive
rm backend_deploy.tar.gz

echo "🎉 Deployment Process Finished!"
