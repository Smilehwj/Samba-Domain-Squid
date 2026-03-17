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
