#!/bin/bash

# Configuration
PEM_KEY="/Users/howardlee.superinsight/Downloads/shimonn.pem"
EC2_HOST="ec2-user@ec2-13-114-217-251.ap-northeast-1.compute.amazonaws.com"

echo "🔍 Checking Remote Server Status..."

ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'EOF'
    echo "🐳 Docker Containers:"
    docker ps -a

    echo -e "\n📝 Backend Logs (Last 50 lines):"
    docker logs --tail 50 backend

    echo -e "\n🔌 Port 3000 Status:"
    netstat -tulpn | grep 3000 || echo "Port 3000 not found"
EOF
