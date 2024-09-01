#!/bin/bash

# 检测系统架构
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    echo "此脚本仅支持 ARM 架构系统。您的架构为: $ARCH"
    exit 1
fi

# 获取当前 BBR 状态
CURRENT_ALGO=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
CURRENT_QDISC=$(sysctl net.core.default_qdisc | awk '{print $3}')

# 欢迎信息
echo "欢迎使用本脚本"
echo "当前 TCP 拥塞控制算法：$CURRENT_ALGO"
echo "当前队列管理算法：$CURRENT_QDISC"
echo "您可以选择以下操作："
echo "1. 安装 BBR v3"
echo "2. 检查是否为 BBR v3"
echo "3. 查看 BBR 是否开启"
echo "4. 开启或关闭 BBR"
echo "5. 选择 TCP 拥塞控制算法和队列管理算法，并显示当前使用的算法"
echo "作者：Joey"
echo "博客：https://jhb.ovh"
echo "反馈群组：https://t.me/+ft-zI76oovgwNmRh"

# 提示用户选择操作
echo -n "请选择一个操作 (1-5): "
read -r ACTION

case $ACTION in
    1)
        # 安装 BBR v3
        echo "您选择了安装 BBR v3。"
        
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

        echo "安装和配置完成，请重启系统以加载新内核。"
        ;;

    2)
        # 检查是否为 BBR v3
        echo "您选择了检查是否为 BBR v3。"
        sudo modinfo tcp_bbr
        ;;

    3)
        # 查看 BBR 是否开启
        echo "您选择了查看 BBR 是否开启。"
        sysctl net.ipv4.tcp_congestion_control
        sysctl net.core.default_qdisc
        ;;

    4)
        # 开启或关闭 BBR
        echo "您选择了开启或关闭 BBR。"

        # 显示当前 BBR 状态
        CURRENT_ALGO=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
        CURRENT_QDISC=$(sysctl net.core.default_qdisc | awk '{print $3}')
        
        echo "当前 BBR 状态："
        echo "TCP 拥塞控制算法：$CURRENT_ALGO"
        echo "队列管理算法：$CURRENT_QDISC"

        echo "请选择操作："
        echo "1. 开启 BBR"
        echo "2. 关闭 BBR"
        echo -n "请输入选项编号 (1 或 2): "
        read -r BBR_ACTION

        if [[ "$BBR_ACTION" == "1" ]]; then
            echo "开启 BBR..."
            echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
            echo "BBR 已开启。"
        elif [[ "$BBR_ACTION" == "2" ]]; then
            echo "关闭 BBR..."
            sudo sed -i '/net.core.default_qdisc=fq/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=cubic" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
            echo "BBR 已关闭，切换到 cubic。"
        else
            echo "无效选项，请输入 1 或 2。"
        fi
        ;;

    5)
        # 选择 TCP 拥塞控制算法和队列管理算法，并显示当前算法
        echo "您选择了选择 TCP 拥塞控制算法和队列管理算法。"

        # 显示当前配置
        CURRENT_ALGO=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
        CURRENT_QDISC=$(sysctl net.core.default_qdisc | awk '{print $3}')

        echo "当前 TCP 拥塞控制算法：$CURRENT_ALGO"
        echo "当前队列管理算法：$CURRENT_QDISC"

        echo "可用的 TCP 拥塞控制算法有："
        echo "1. bbr"
        echo "2. cubic"
        echo "3. reno"
        echo -n "请输入要设置的 TCP 拥塞控制算法编号 (1-3): "
        read -r ALGO_NUM

        case $ALGO_NUM in
            1) ALGO="bbr" ;;
            2) ALGO="cubic" ;;
            3) ALGO="reno" ;;
            *)
                echo "无效选项，已退出。"
                exit 1
                ;;
        esac

        echo "可用的队列管理算法有："
        echo "1. fq"
        echo "2. pfifo_fast"
        echo "3. fq_codel"
        echo -n "请输入要设置的队列管理算法编号 (1-3): "
        read -r QDISC_NUM

        case $QDISC_NUM in
            1) QDISC="fq" ;;
            2) QDISC="pfifo_fast" ;;
            3) QDISC="fq_codel" ;;
            *)
                echo "无效选项，已退出。"
                exit 1
                ;;
        esac

        echo "设置 TCP 拥塞控制算法为 $ALGO 和队列管理算法为 $QDISC..."
        sudo sed -i "/net.core.default_qdisc/d" /etc/sysctl.conf
        sudo sed -i "/net.ipv4.tcp_congestion_control/d" /etc/sysctl.conf
        echo "net.core.default_qdisc=$QDISC" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=$ALGO" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        echo "TCP 拥塞控制算法已设置为 $ALGO，队列管理算法已设置为 $QDISC。"
        ;;

    *)
        echo "无效的选项。请输入 1 到 5 之间的数字。"
        ;;
esac

echo "操作完成。"
