#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "请使用 root 用户或者 sudo 权限执行脚本。"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    if command -v curl &> /dev/null; then
         curl -fsSL https://get.docker.com -o get-docker.sh
    elif command -v wget &> /dev/null; then
         wget -O get-docker.sh https://get.docker.com
    else
         echo "错误：curl 和 wget 都不可用，请安装其中之一。"
         exit 1
    fi

    sh get-docker.sh
    rm -f get-docker.sh
fi

media_path=""

modifyMediaLocation(){
    read -p "请输入存储的媒体绝对路径(注意权限，结尾不带/): " media_path
    mkdir -p $media_path/TV
    mkdir -p $media_path/Movies
    sed -i "s|/test|$media_path|g" ./docker-compose.yml
}

textReplacement(){
    old_text="$1"
    new_text="$2"
    # echo "替换 $old_text 为 $new_text"
    sed -i "s|$old_text|$new_text|g" ./docker-compose.yml
}

echo "请选择要安装方式:"
echo "1. 使用 Bridge 网络"
echo "2. 使用 Macvlan 网络"

read choice

case $choice in
    1)
        modifyMediaLocation
        ;;
    2)
        declare -A ip_map
        cp ./example/macvlan.yml ./docker-compose.yml
        modifyMediaLocation

        read -p "请输入接口(例如：eth0): " interface
        ip_map["eth0"]=$interface
        read -p "请输入网段(例如：192.168.1.0/24): " subnet
        ip_map["192.168.1.0/24"]=$subnet
        read -p "请输入网关(例如：192.168.1.1): " gateway
        ip_map["gateway: 192.168.1.1"]="gateway: $gateway"
        read -p "请输入 jellyfin 地址(例如：192.168.1.10): " jellyfin_ip
        ip_map["192.168.1.10"]=$jellyfin_ip
        read -p "请输入 qBittorrent 地址(例如：192.168.1.11): " qBittorrent_ip
        ip_map["192.168.1.11"]=$qBittorrent_ip
        read -p "请输入 flaresolverr 地址(例如：192.168.1.12): " flaresolverr_ip
        ip_map["192.168.1.12"]=$flaresolverr_ip
        read -p "请输入 prowlarr 地址(例如：192.168.1.13): " prowlarr_ip
        ip_map["192.168.1.13"]=$prowlarr_ip
        read -p "请输入 sonarr 地址(例如：192.168.1.14): " sonarr_ip
        ip_map["192.168.1.14"]=$sonarr_ip
        read -p "请输入 radarr 地址(例如：192.168.1.15): " radarr_ip
        ip_map["192.168.1.15"]=$radarr_ip
        read -p "请输入 jellyseerr 地址(例如：192.168.1.16): " jellyseerr_ip
        ip_map["192.168.1.16"]=$jellyseerr_ip
        read -p "请输入 jproxy 地址(例如：192.168.1.17): " jproxy_ip
        ip_map["192.168.1.17"]=$jproxy_ip
        read -p "请输入 chinesesubfinder 地址(例如：192.168.1.18): " chinesesubfinder_ip
        ip_map["192.168.1.18"]=$chinesesubfinder_ip
        read -p "请输入 peerbanhelper 地址(例如：192.168.1.19): " peerbanhelper_ip
        ip_map["192.168.1.19"]=$peerbanhelper_ip

        for ip in "${!ip_map[@]}"; do
          textReplacement "$ip" "${ip_map[$ip]}" 
        done
        ;;
    *)
        echo "无效的选择"
        exit 1
        ;;
esac

docker compose up -d
if ! [ $? -eq 0 ]; then
  echo "安装失败，请查看docker compose日志"
  exit 1
fi

chown -R 1000:1000 $media_path

echo "安装完成。请阅读README中的端口或者自行查看 docker-compose.yml 文件"