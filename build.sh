#!/bin/bash
set -e

echo "================================================"
echo "Building Samba AD Domain Controller and Client"
echo "================================================"

# 构建Samba AD镜像
echo "Building Samba AD Domain Controller..."
cd samba-ad
docker build -t samba-ad-dc:latest .
cd ..

# 构建客户端镜像
echo "Building Domain Client..."
cd domain-client
docker build -t domain-client:latest .
cd ..

echo "================================================"
echo "Build completed!"
echo "Images created:"
echo "  - samba-ad-dc:latest"
echo "  - domain-client:latest"
echo "================================================"
echo ""
echo "To start the environment:"
echo "  docker-compose up -d"
echo ""
echo "To stop the environment:"
echo "  docker-compose down"
echo ""
echo "To access Samba AD:"
echo "  docker exec -it samba-ad-dc /bin/bash"
echo ""
echo "To access domain client:"
echo "  docker exec -it domain-client /bin/bash"