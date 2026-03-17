#!/bin/bash
set -e

echo "Starting Samba AD environment..."
docker-compose up -d

echo "Waiting for services to start..."
sleep 10

echo "Checking Samba AD status..."
docker exec samba-ad-dc samba-tool domain info 127.0.0.1

echo "Checking client domain join..."
docker exec domain-client net ads testjoin

echo "================================================"
echo "Environment started successfully!"
echo "================================================"
echo "Samba AD Domain Controller:"
echo "  Hostname: dc01.lab.local"
echo "  Domain: LAB"
echo "  Realm: LAB.LOCAL"
echo "  Admin password: AdminPass123!"
echo ""
echo "Domain Client:"
echo "  Hostname: client01.lab.local"
echo "  Joined to domain: LAB"
echo ""
echo "To test domain authentication:"
echo "  docker exec domain-client wbinfo -u"
echo "  docker exec domain-client getent passwd"
echo "================================================"