#!/bin/bash
set -e

echo "Starting Samba AD domain initialization..."

# 设置主机名
hostnamectl set-hostname "${SAMBA_HOST_NAME}.${SAMBA_REALM,,}"
echo "Hostname set to: ${SAMBA_HOST_NAME}.${SAMBA_REALM,,}"

# 生成配置文件
envsubst < /etc/samba/smb.conf.template > /etc/samba/smb.conf

# 初始化域
echo "Initializing Samba AD domain..."
samba-tool domain provision \
    --use-rfc2307 \
    --realm="${SAMBA_REALM}" \
    --domain="${SAMBA_DOMAIN}" \
    --adminpass="${SAMBA_ADMIN_PASSWORD}" \
    --server-role="dc" \
    --dns-backend="SAMBA_INTERNAL" \
    --host-name="${SAMBA_HOST_NAME}" \
    --option="dns forwarder = ${SAMBA_DNS_FORWARDER}"

# 标记为已初始化
touch /var/lib/samba/.initialized

echo "================================================"
echo "Samba AD Domain Controller initialized!"
echo "================================================"
echo "Domain: ${SAMBA_DOMAIN}"
echo "Realm: ${SAMBA_REALM}"
echo "Administrator password: ${SAMBA_ADMIN_PASSWORD}"
echo "Hostname: ${SAMBA_HOST_NAME}.${SAMBA_REALM,,}"
echo "================================================"