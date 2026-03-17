#!/bin/bash
set -e

echo "================================================"
echo "Domain Client Container"
echo "================================================"
echo "Domain: ${DOMAIN}"
echo "Realm: ${REALM}"
echo "Domain Server: ${DOMAIN_SERVER}"
echo "Client Hostname: ${CLIENT_HOSTNAME}"
echo "================================================"

# 设置时区
if [ -n "${TZ}" ]; then
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
fi

# 设置主机名
if [ -n "${CLIENT_HOSTNAME}" ]; then
    hostnamectl set-hostname "${CLIENT_HOSTNAME}"
    echo "Hostname set to: ${CLIENT_HOSTNAME}"
fi

# 启动时间同步
echo "Starting time synchronization..."
chronyd -d &

# 检查是否已加入域
if [ ! -f /etc/samba/domain_joined ] && [ -n "${DOMAIN_SERVER}" ]; then
    echo "Attempting to join domain..."
    /usr/local/bin/join-domain.sh
    if [ $? -eq 0 ]; then
        touch /etc/samba/domain_joined
    fi
fi

exec "$@"