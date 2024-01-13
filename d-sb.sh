#!/bin/bash

# 开启BBR
modprobe tcp_bbr
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 更新系统
apt update
apt upgrade -y

# 安装依赖工具
apt install -y apt-transport-https ca-certificates curl software-properties-common

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置稳定的Docker存储库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新包列表
apt update

# 安装Docker引擎
apt install -y docker-ce docker-ce-cli containerd.io

# 安装Docker Compose 1.29版本
curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 创建docker-compose.yml文件并提示用户输入密码
read -p "请输入shadowsocks-libev密码: " ss_password
cat <<EOF > docker-compose.yml
version: '3'
services:
  shadowsocks:
    image: shadowsocks/shadowsocks-libev
    ports:
      - "8388:8388"
    environment:
      - PASSWORD=$ss_password
      - METHOD=aes-256-gcm
    restart: always
EOF

# 启动shadowsocks-libev服务
docker-compose up -d

# 设置Docker开机自启
systemctl enable docker

echo "脚本执行完成！"
