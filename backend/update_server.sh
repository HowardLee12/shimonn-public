#!/bin/bash
# Run this script ON the EC2 instance

CONTAINER_NAME="shimonn-backend"
ECR_REPO="418445456105.dkr.ecr.ap-northeast-1.amazonaws.com/shimonn"

echo "⬇️ Pulling latest image..."
docker pull $ECR_REPO:latest

echo "🔄 Restarting container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p 3000:3000 \
  --env-file ~/shimonn.env \
  $ECR_REPO:latest

echo "⏳ Waiting for container to start..."
sleep 5

echo "🛠 Running Database Migration (Adding streak_days)..."
docker exec $CONTAINER_NAME node migrations/add_streak_column.js

echo "✅ Update Complete!"
docker logs --tail 10 $CONTAINER_NAME
