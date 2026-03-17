#!/bin/bash
set -e

echo "Configuring Samba..."

# 更新配置文件
if [ -f /etc/samba/smb.conf.template ]; then
    envsubst < /etc/samba/smb.conf.template > /etc/samba/smb.conf
fi

# 设置正确的权限
chown -R root:root /var/lib/samba
chmod 755 /var/lib/samba
chmod 750 /var/lib/samba/private
chmod 750 /var/lib/samba/sysvol

echo "Samba configuration updated."