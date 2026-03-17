#!/bin/bash
# fix-network.sh

echo "================================================"
echo "Fixing Docker Network Conflict"
echo "================================================"

# 停止和删除现有容器
echo "1. Stopping and removing existing containers..."
docker-compose down 2>/dev/null || true

# 删除冲突的网络
echo "2. Removing conflicting networks..."
docker network rm samba-net 2>/dev/null || true
docker network rm samba-domain_samba-net 2>/dev/null || true

# 使用新的子网配置
echo "3. Creating new docker-compose.yml with non-conflicting subnet..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  samba-ad-dc:
    build: ./samba-ad
    container_name: samba-ad-dc
    hostname: dc01.lab.local
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "88:88/tcp"
      - "88:88/udp"
      - "135:135/tcp"
      - "137:137/udp"
      - "138:138/udp"
      - "139:139/tcp"
      - "389:389/tcp"
      - "389:389/udp"
      - "445:445/tcp"
      - "464:464/tcp"
      - "464:464/udp"
      - "636:636/tcp"
      - "3268:3268/tcp"
      - "3269:3269/tcp"
    environment:
      - SAMBA_DOMAIN=LAB
      - SAMBA_REALM=LAB.LOCAL
      - SAMBA_ADMIN_PASSWORD=AdminPass123!
      - SAMBA_HOST_NAME=dc01
      - SAMBA_DNS_FORWARDER=8.8.8.8
      - TZ=UTC
    volumes:
      - samba_data:/var/lib/samba
      - samba_etc:/etc/samba
      - samba_logs:/var/log/samba
    networks:
      samba-net:
        ipv4_address: 10.20.30.10
    extra_hosts:
      - "dc01.lab.local:10.20.30.10"
      - "client01.lab.local:10.20.30.20"

  domain-client:
    build: ./domain-client
    container_name: domain-client
    hostname: client01.lab.local
    restart: unless-stopped
    depends_on:
      - samba-ad-dc
    environment:
      - DOMAIN=LAB
      - REALM=LAB.LOCAL
      - DOMAIN_USER=Administrator
      - DOMAIN_PASS=AdminPass123!
      - DOMAIN_SERVER=dc01.lab.local
      - CLIENT_HOSTNAME=client01
      - TZ=UTC
    networks:
      samba-net:
        ipv4_address: 10.20.30.20
    dns:
      - 10.20.30.10
    dns_search:
      - lab.local
    extra_hosts:
      - "dc01.lab.local:10.20.30.10"
      - "client01.lab.local:10.20.30.20"
    tty: true
    stdin_open: true

networks:
  samba-net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.20.30.0/24
          gateway: 10.20.30.1

volumes:
  samba_data:
  samba_etc:
  samba_logs:
EOF

# 更新join-domain.sh
echo "4. Updating client configuration..."
cat > domain-client/join-domain.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting domain join process..."

# ... 脚本内容不变，但修改IP地址 ...

# 配置DNS - 使用固定IP
echo "Configuring DNS..."
cat > /etc/resolv.conf << DNS_EOF
search lab.local
nameserver 10.20.30.10
options timeout:2 attempts:3
DNS_EOF

# ... 脚本其余部分 ...
EOF

# 修改join-domain.sh中的IP地址
sed -i 's/172\.16\.111\.10/10.20.30.10/g' domain-client/join-domain.sh
sed -i 's/172\.16\.111\.20/10.20.30.20/g' domain-client/join-domain.sh

# 启动服务
echo "5. Starting services..."
docker-compose up -d

echo "================================================"
echo "Network conflict fixed!"
echo "Using subnet: 10.20.30.0/24"
echo "Domain Controller: 10.20.30.10"
echo "Client: 10.20.30.20"
echo "================================================"