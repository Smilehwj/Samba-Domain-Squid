#!/bin/bash
# network-init.sh
# 创建Docker网络并配置主机路由

set -e

echo "================================================"
echo "Setting up network for Samba AD environment"
echo "================================================"

# 创建Docker网络
echo "Creating Docker network..."
docker network create samba-net 2>/dev/null || true

# 如果使用自定义子网
echo "Creating custom Docker network with subnet 172.16.0.0/16..."
docker network rm samba-net 2>/dev/null || true
docker network create \
  --driver bridge \
  --subnet=172.16.0.0/16 \
  --ip-range=172.16.111.0/24 \
  --gateway=172.16.0.1 \
  samba-net

echo "Docker network created:"
docker network inspect samba-net --format='{{range .IPAM.Config}}{{.Subnet}} -> {{.Gateway}}{{end}}'

echo ""
echo "To allow external access, you may need to:"
echo "1. Configure firewall rules:"
echo "   sudo firewall-cmd --permanent --zone=public --add-port=53/tcp"
echo "   sudo firewall-cmd --permanent --zone=public --add-port=53/udp"
echo "   sudo firewall-cmd --permanent --zone=public --add-port=389/tcp"
echo "   sudo firewall-cmd --permanent --zone=public --add-port=445/tcp"
echo "2. Add route on your host (if needed):"
echo "   sudo ip route add 172.16.0.0/16 via 172.16.111.1"
echo ""
echo "================================================"
echo "Network setup complete!"
echo "================================================"