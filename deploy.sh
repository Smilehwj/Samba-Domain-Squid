#!/bin/bash
# deploy.sh

set -e

echo "================================================"
echo "Deploying Samba AD Domain with Custom Network"
echo "================================================"

# 检查Docker和Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed"
    exit 1
fi

# 网络配置
NETWORK_SUBNET="172.16.0.0/16"
IP_RANGE="172.16.111.0/24"
GATEWAY="172.16.0.1"
DOMAIN_CONTROLLER_IP="172.16.111.10"
CLIENT_IP="172.16.111.20"

echo "Network Configuration:"
echo "  Subnet: ${NETWORK_SUBNET}"
echo "  IP Range: ${IP_RANGE}"
echo "  Gateway: ${GATEWAY}"
echo "  Domain Controller IP: ${DOMAIN_CONTROLLER_IP}"
echo "  Client IP: ${CLIENT_IP}"
echo ""

# 清理旧的容器
echo "Cleaning up old containers..."
docker-compose down 2>/dev/null || true

# 创建Docker网络
echo "Setting up Docker network..."
docker network rm samba-net 2>/dev/null || true
docker network create \
  --driver bridge \
  --subnet=${NETWORK_SUBNET} \
  --ip-range=${IP_RANGE} \
  --gateway=${GATEWAY} \
  samba-net

# 构建镜像
echo "Building images..."
docker-compose build

# 启动服务
echo "Starting services..."
docker-compose up -d

# 等待服务启动
echo "Waiting for services to start (30 seconds)..."
sleep 30

# 检查服务状态
echo "Checking service status..."
echo ""
echo "1. Domain Controller Status:"
docker exec samba-ad-dc samba-tool domain info 127.0.0.1 || echo "Domain controller not ready yet"

echo ""
echo "2. Network Configuration:"
docker exec samba-ad-dc ip addr show | grep "inet "
docker exec domain-client ip addr show | grep "inet "

echo ""
echo "3. DNS Resolution Test:"
docker exec domain-client nslookup dc01.lab.local || echo "DNS not responding yet"

echo ""
echo "4. Domain Join Test:"
docker exec domain-client net ads testjoin 2>/dev/null || echo "Client not joined to domain yet"

echo ""
echo "================================================"
echo "Deployment Summary"
echo "================================================"
echo "Domain Controller:"
echo "  Hostname: dc01.lab.local"
echo "  IP Address: ${DOMAIN_CONTROLLER_IP}"
echo "  Domain: LAB"
echo "  Realm: LAB.LOCAL"
echo "  Admin Password: AdminPass123!"
echo ""
echo "Domain Client:"
echo "  Hostname: client01.lab.local"
echo "  IP Address: ${CLIENT_IP}"
echo "  Domain: LAB"
echo ""
echo "Network Configuration:"
echo "  Subnet: ${NETWORK_SUBNET}"
echo "  IP Range: ${IP_RANGE}"
echo "  Gateway: ${GATEWAY}"
echo "  DNS Server: ${DOMAIN_CONTROLLER_IP}"
echo ""
echo "Access Information:"
echo "  To access Domain Controller: docker exec -it samba-ad-dc /bin/bash"
echo "  To access Domain Client: docker exec -it domain-client /bin/bash"
echo "  To view logs: docker-compose logs -f"
echo ""
echo "Testing Commands:"
echo "  Test DNS: docker exec domain-client nslookup dc01.lab.local"
echo "  Test Kerberos: docker exec domain-client kinit Administrator@LAB.LOCAL"
echo "  List domain users: docker exec domain-client wbinfo -u"
echo ""
echo "================================================"
echo "Deployment complete!"
echo "================================================"