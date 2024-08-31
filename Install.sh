#!/bin/bash

# 欢迎信息
echo "欢迎使用 本脚本"
echo "更新内核并启用 BBRv3 拥塞控制算法。"
echo "作者：Joey"
echo "博客：https://jhb.ovh"
echo "反馈群组：https://t.me/+ft-zI76oovgwNmRh"

# 检测系统架构
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    echo "此脚本仅支持 ARM 架构系统。您的架构为: $ARCH"
    exit 1
fi

# 定义文件下载路径
BASE_URL="https://jhb.ovh/jb/nh"
FILES=(
    "linux-image-6.4.0+_6.4.0-g7542cc7c41c0-1_arm64.deb"
    "linux-libc-dev_6.4.0-g7542cc7c41c0-1_arm64.deb"
    "linux-headers-6.4.0+_6.4.0-g7542cc7c41c0-1_arm64.deb"
    "linux-image-6.4.0+-dbg_6.4.0-g7542cc7c41c0-1_arm64.deb"
)

# 下载文件并安装
for FILE in "${FILES[@]}"; do
    echo "正在下载 $FILE ..."
    wget "$BASE_URL/$FILE" -O "/tmp/$FILE"
    if [ $? -ne 0 ]; then
        echo "下载 $FILE 失败！" >&2
        exit 1
    fi
done

echo "正在安装下载的文件..."
sudo dpkg -i /tmp/linux-*.deb

# 清理下载的文件
echo "清理下载的临时文件..."
rm /tmp/linux-*.deb

# 更新启动项
echo "更新 GRUB 配置..."
sudo update-grub

# 开启 BBR
echo "开启 BBR..."
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 验证 BBR 是否启用
echo "验证 BBR 状态..."
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

echo "安装和配置完成，请重启系统以加载新内核。"
