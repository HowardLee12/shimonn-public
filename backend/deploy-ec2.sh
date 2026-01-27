#!/bin/bash

# ShiMon Backend Deployment Script for EC2

echo "🚀 Starting ShiMon Backend Deployment..."

# Variables
ECR_REPO="418445456105.dkr.ecr.ap-northeast-1.amazonaws.com/shimonn"
CONTAINER_NAME="shimonn-backend"
PORT=3000
ENV_FILE="$HOME/shimonn.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found!"
    echo "Please create it with DATABASE_URL, RESEND_API_KEY, etc."
    exit 1
fi

# Stop and remove existing container
echo "📦 Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin \
  418445456105.dkr.ecr.ap-northeast-1.amazonaws.com

# Pull latest image
echo "⬇️  Pulling latest image from ECR..."
docker pull $ECR_REPO:latest

# Run container with .env file
echo "▶️  Starting container..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:$PORT \
  --env-file $ENV_FILE \
  $ECR_REPO:latest

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 5

# Check if container is running
echo "✅ Checking container status..."
if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container is running!"
    docker ps | grep $CONTAINER_NAME
    
    # Get EC2 public IP
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    
    echo ""
    echo "🎉 Deployment complete!"
    echo "📊 View logs: docker logs -f $CONTAINER_NAME"
    echo "🌐 API URL: http://$PUBLIC_IP:$PORT"
    echo "🧪 Test: curl http://$PUBLIC_IP:$PORT/api/test"
else
    echo "❌ Container failed to start!"
    echo "📋 Checking logs..."
    docker logs $CONTAINER_NAME
    exit 1
fi
