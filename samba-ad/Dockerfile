FROM rockylinux:9-minimal

LABEL maintainer="Your Name <you@example.com>"
LABEL description="Samba Active Directory Domain Controller"
LABEL version="1.0"

ENV SAMBA_DOMAIN="LAB" \
    SAMBA_REALM="LAB.LOCAL" \
    SAMBA_ADMIN_PASSWORD="AdminPass123!" \
    SAMBA_HOST_NAME="dc01" \
    SAMBA_DNS_FORWARDER="8.8.8.8" \
    TZ="UTC"

# 安装必要的软件包
RUN microdnf update -y && \
    microdnf install -y \
    samba \
    samba-common \
    samba-common-tools \
    samba-client \
    samba-winbind \
    samba-winbind-clients \
    krb5-server \
    krb5-workstation \
    bind \
    bind-utils \
    procps-ng \
    net-tools \
    iproute \
    hostname \
    chrony \
    tzdata \
    openssh-clients \
    vim-minimal \
    which \
    lsof \
    gettext \
    && microdnf clean all

# 创建必要的目录
RUN mkdir -p /var/lib/samba/private \
    /var/lib/samba/sysvol \
    /etc/samba \
    /var/log/samba \
    /var/run/samba \
    /var/lib/krb5kdc

# 复制配置文件
COPY krb5.conf /etc/krb5.conf
COPY smb.conf.template /etc/samba/smb.conf.template
COPY samba-init.sh /usr/local/bin/samba-init.sh
COPY samba-config.sh /usr/local/bin/samba-config.sh
COPY entrypoint.sh /entrypoint.sh

# 设置权限
RUN chmod 755 /usr/local/bin/samba-init.sh && \
    chmod 755 /usr/local/bin/samba-config.sh && \
    chmod 755 /entrypoint.sh

# 配置chrony
RUN echo "server pool.ntp.org iburst" > /etc/chrony.conf && \
    echo "driftfile /var/lib/chrony/drift" >> /etc/chrony.conf && \
    echo "makestep 1.0 3" >> /etc/chrony.conf && \
    echo "rtcsync" >> /etc/chrony.conf

# 暴露端口
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 88/tcp
EXPOSE 88/udp
EXPOSE 135/tcp
EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139/tcp
EXPOSE 389/tcp
EXPOSE 389/udp
EXPOSE 445/tcp
EXPOSE 464/tcp
EXPOSE 464/udp
EXPOSE 636/tcp
EXPOSE 3268/tcp
EXPOSE 3269/tcp

VOLUME ["/var/lib/samba", "/etc/samba", "/var/log/samba"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["samba"]