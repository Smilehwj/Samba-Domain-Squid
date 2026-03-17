#!/bin/bash
# test-environment.sh

set -e

echo "================================================"
echo "Testing Samba AD Environment"
echo "================================================"

# 检查容器状态
echo "1. Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "2. Testing network connectivity..."
echo "Pinging domain controller from client..."
docker exec domain-client ping -c 3 172.16.111.10

echo ""
echo "3. Testing DNS resolution..."
echo "Resolving dc01.lab.local:"
docker exec domain-client nslookup dc01.lab.local
echo ""
echo "Resolving client01.lab.local:"
docker exec domain-client nslookup client01.lab.local

echo ""
echo "4. Testing Samba AD domain..."
echo "Domain info:"
docker exec samba-ad-dc samba-tool domain info 127.0.0.1

echo ""
echo "5. Testing domain join..."
docker exec domain-client net ads testjoin
docker exec domain-client net ads status

echo ""
echo "6. Testing Kerberos..."
echo "Getting Kerberos ticket:"
docker exec domain-client bash -c 'echo "AdminPass123!" | kinit Administrator@LAB.LOCAL 2>&1'
docker exec domain-client klist

echo ""
echo "7. Testing LDAP..."
echo "LDAP search:"
docker exec domain-client ldapsearch -x -h 172.16.111.10 -b "dc=lab,dc=local" 2>&1 | head -20

echo ""
echo "8. Testing Winbind..."
echo "Domain users:"
docker exec domain-client wbinfo -u | head -5
echo "..."
echo "Domain groups:"
docker exec domain-client wbinfo -g | head -5
echo "..."

echo ""
echo "9. Testing authentication..."
docker exec domain-client wbinfo -a "LAB\\Administrator%AdminPass123!" 2>&1 | head -10

echo ""
echo "10. Testing reverse DNS..."
echo "Resolving 172.16.111.10:"
docker exec domain-client nslookup 172.16.111.10
echo "Resolving 172.16.111.20:"
docker exec domain-client nslookup 172.16.111.20

echo ""
echo "================================================"
echo "Test completed!"
echo "================================================"