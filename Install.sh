#!/bin/bash

# 检测系统架构
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    echo -e "\033[31m此脚本仅支持 ARM 架构系统。您的架构为: $ARCH\033[0m"
    exit 1
fi

# 获取当前 BBR 状态
CURRENT_ALGO=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
CURRENT_QDISC=$(sysctl net.core.default_qdisc | awk '{print $3}')

# 欢迎信息
echo -e "\033[34m欢迎使用本脚本\033[0m"
echo "当前 TCP 拥塞控制算法：$CURRENT_ALGO"
echo "当前队列管理算法：$CURRENT_QDISC"
echo "您可以选择以下操作："
echo "1. 安装 BBR v3"
echo "2. 检查是否为 BBR v3"
echo "3. 使用 BBR + FQ 加速"
echo "4. 使用 BBR + FQ_PIE 加速"
echo "5. 使用 BBR + CAKE 加速"
echo "6. 开启或关闭 BBR"
echo -e "\033[34m作者：Joey\033[0m"
echo -e "\033[34m博客：https://jhb.ovh\033[0m"
echo -e "\033[34m反馈群组：https://t.me/+ft-zI76oovgwNmRh\033[0m"

# 提示用户选择操作
echo -n "请选择一个操作 (1-6): "
read -r ACTION

case $ACTION in
    1)
        # 安装 BBR v3
        echo -e "\033[32m您选择了安装 BBR v3。\033[0m"
        
        # 定义文件下载路径
        BASE_URL="https://jhb.ovh/jb/nh"
        FILES=(
            "linux-image-6.10.7+_6.10.7-g7542cc7c41c0-1_arm64.deb"
            "linux-libc-dev_6.10.7-g7542cc7c41c0-1_arm64.deb"
            "linux-headers-6.10.7+_6.10.7-g7542cc7c41c0-1_arm64.deb"
            "linux-image-6.10.7+-dbg_6.10.7-g7542cc7c41c0-1_arm64.deb"
        )

        # 下载文件并安装
        for FILE in "${FILES[@]}"; do
            echo "正在下载 $FILE ..."
            wget "$BASE_URL/$FILE" -O "/tmp/$FILE"
            if [[ $? -ne 0 ]]; then
                echo -e "\033[31m下载 $FILE 失败！\033[0m" >&2
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

        echo -e "\033[32m安装和配置完成，请重启系统以加载新内核。\033[0m"
        ;;

    2)
        # 检查是否为 BBR v3
        echo -e "\033[32m您选择了检查是否为 BBR v3。\033[0m"
        BBR_INFO=$(sudo modinfo tcp_bbr)
        BBR_VERSION=$(echo "$BBR_INFO" | grep -i "version:" | awk '{print $2}')

        if [[ "$BBR_VERSION" == *"3"* ]]; then
            echo -e "\033[32m检测到 BBR v3 已安装。\033[0m"
        else
            echo -e "\033[31m未检测到 BBR v3。当前版本：$BBR_VERSION\033[0m"
        fi
        ;;

    3)
        # 使用 BBR + FQ 加速
        echo -e "\033[32m您选择了使用 BBR + FQ 加速。\033[0m"
        sudo sysctl -w net.core.default_qdisc=fq
        sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
        echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        echo -e "\033[32m已设置为 BBR + FQ。\033[0m"
        ;;

    4)
        # 使用 BBR + FQ_PIE 加速
        echo -e "\033[32m您选择了使用 BBR + FQ_PIE 加速。\033[0m"
        sudo modprobe fq_pie
        sudo sysctl -w net.core.default_qdisc=fq_pie
        sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
        echo "net.core.default_qdisc=fq_pie" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        echo -e "\033[32m已设置为 BBR + FQ_PIE。\033[0m"
        ;;

    5)
        # 使用 BBR + CAKE 加速
        echo -e "\033[32m您选择了使用 BBR + CAKE 加速。\033[0m"
        sudo modprobe sch_cake
        sudo sysctl -w net.core.default_qdisc=cake
        sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
        echo "net.core.default_qdisc=cake" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        echo -e "\033[32m已设置为 BBR + CAKE。\033[0m"
        ;;

    6)
        # 开启或关闭 BBR
        echo -e "\033[32m您选择了开启或关闭 BBR。\033[0m"

        echo "请选择操作："
        echo "1. 开启 BBR"
        echo "2. 关闭 BBR"
        echo -n "请输入选项编号 (1 或 2): "
        read -r BBR_ACTION

        if [[ "$BBR_ACTION" == "1" ]]; then
            if [[ "$CURRENT_ALGO" == "bbr" && "$CURRENT_QDISC" == "fq" ]]; then
                echo -e "\033[33mBBR 已开启，无需重复设置。\033[0m"
            else
                echo "开启 BBR..."
                sudo sysctl -w net.core.default_qdisc=fq
                sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
                
                # 将设置写入配置文件以便重启后生效
                sudo sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
                sudo sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
                echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
                echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
                
                echo -e "\033[32mBBR 已开启。\033[0m"
            fi
        elif [[ "$BBR_ACTION" == "2" ]]; then
            if [[ "$CURRENT_ALGO" != "bbr" ]]; then
                echo -e "\033[33mBBR 当前未开启，无需关闭。\033[0m"
            else
                echo "关闭 BBR..."
                sudo sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
                sudo sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
                echo "net.ipv4.tcp_congestion_control=cubic" | sudo tee -a /etc/sysctl.conf
                sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
                sudo sysctl -w net.core.default_qdisc=pfifo_fast
                
                echo -e "\033[32mBBR 已关闭，切换到 cubic。\033[0m"
            fi
        else
            echo -e "\033[31m无效选项，请输入 1 或 2。\033[0m"
        fi
        ;;

    *)
        echo -e "\033[31m无效选项，请输入 1 到 6。\033[0m"
        ;;
esac
