#!/bin/bash
set -e

echo "================================================"
echo "Samba AD Domain Controller"
echo "================================================"
echo "Domain: ${SAMBA_DOMAIN:-LAB}"
echo "Realm: ${SAMBA_REALM:-LAB.LOCAL}"
echo "Hostname: ${SAMBA_HOST_NAME:-dc01}"
echo "DNS Forwarder: ${SAMBA_DNS_FORWARDER:-8.8.8.8}"
echo "================================================"

# 设置时区
if [ -n "${TZ}" ]; then
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
fi

# 启动时间同步
echo "Starting time synchronization..."
chronyd -d &
sleep 2

# 检查初始化状态
if [ ! -f /var/lib/samba/.initialized ]; then
    echo "First boot detected, initializing domain..."
    /usr/local/bin/samba-init.sh
else
    echo "Using existing configuration..."
    /usr/local/bin/samba-config.sh
fi

# 启动Samba
echo "Starting Samba AD Domain Controller..."
exec "$@"