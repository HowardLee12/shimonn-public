#!/bin/bash

# Configuration
ECR_REPO="418445456105.dkr.ecr.ap-northeast-1.amazonaws.com/shimonn"
REGION="ap-northeast-1"

echo "🚀 Starting Local Build & Push..."

# 1. Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin 418445456105.dkr.ecr.ap-northeast-1.amazonaws.com || { echo "❌ ECR Login Failed"; exit 1; }

# 2. Build for AMD64 (Required for EC2)
echo "🔨 Building Docker image (linux/amd64)..."
docker buildx build --platform linux/amd64 -t shimonn-backend:latest . || { echo "❌ Build Failed"; exit 1; }

# 3. Tag Image
echo "🏷️ Tagging image..."
docker tag shimonn-backend:latest $ECR_REPO:latest

# 4. Push to ECR
echo "⬆️ Pushing to ECR..."
docker push $ECR_REPO:latest || { echo "❌ Push Failed"; exit 1; }

echo "✅ Build & Push Complete!"
echo "👉 Now please SSH into your EC2 instance and run 'backend/update_server.sh' (I will create this next)."
