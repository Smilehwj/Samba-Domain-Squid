#!/bin/bash
# cleanup.sh

set -e

echo "================================================"
echo "Cleaning up Samba AD Environment"
echo "================================================"

echo "1. Stopping and removing containers..."
docker-compose down

echo "2. Removing Docker network..."
docker network rm samba-net 2>/dev/null || echo "Network already removed"

echo "3. Removing volumes..."
docker volume rm samba-ad_samba_data samba-ad_samba_etc samba-ad_samba_logs 2>/dev/null || echo "Volumes already removed"

echo "4. Removing images..."
docker rmi samba-ad-dc:latest domain-client:latest 2>/dev/null || echo "Images already removed"

echo "5. Pruning unused Docker resources..."
docker system prune -f

echo ""
echo "================================================"
echo "Cleanup complete!"
echo "================================================"