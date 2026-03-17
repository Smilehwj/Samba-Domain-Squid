FROM rockylinux:9-minimal

LABEL maintainer="Your Name <you@example.com>"
LABEL description="Linux client joined to Samba AD domain"
LABEL version="1.0"

ENV DOMAIN="LAB" \
    REALM="LAB.LOCAL" \
    DOMAIN_USER="Administrator" \
    DOMAIN_PASS="AdminPass123!" \
    DOMAIN_SERVER="dc01.lab.local" \
    CLIENT_HOSTNAME="client01" \
    TZ="UTC"

# 安装必要的软件包 - 使用SSSD替代nss-pam-ldapd
RUN microdnf update -y && \
    microdnf install -y \
    samba-client \
    samba-winbind \
    samba-winbind-clients \
    krb5-workstation \
    krb5-libs \
    sssd \
    sssd-ad \
    sssd-common \
    sssd-tools \
    authselect \
    oddjob \
    oddjob-mkhomedir \
    adcli \
    realmd \
    net-tools \
    bind-utils \
    iproute \
    hostname \
    chrony \
    tzdata \
    vim-minimal \
    wget \
    curl \
    which \
    gettext \
    && microdnf clean all

# 创建目录
RUN mkdir -p /etc/samba /etc/krb5.conf.d

# 复制配置文件
COPY krb5.conf.template /etc/krb5.conf.template
COPY smb.conf.template /etc/samba/smb.conf.template
COPY join-domain.sh /usr/local/bin/join-domain.sh
COPY entrypoint.sh /entrypoint.sh

# 设置权限
RUN chmod 755 /usr/local/bin/join-domain.sh && \
    chmod 755 /entrypoint.sh

# 配置chrony
RUN echo "server pool.ntp.org iburst" > /etc/chrony.conf && \
    echo "makestep 1.0 3" >> /etc/chrony.conf

# 设置入口点
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]