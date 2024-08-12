# auto-animation

本项目初衷是打造自动化追番流程，国内的平台现在成了正版受害者，花钱看删减

使用 docker compose 一键搭建所有容器

## 使用教程

建议使用**4g及以上的内存**

| 服务 | 地址 |
|---|---|
| jellyfin | `ip:8096` |
| qBittorrent | `ip:8888` |
| flaresolverr | `ip:8191` |
| prowlarr | `ip:9696` |
| sonarr | `ip:8989` |
| radarr | `ip:7878` |
| jellyseerr | `ip:5055` |
| jproxy | `ip:8117` |
| chinesesubfinder | `ip:19035` |
| peerbanhelper | `ip:9898` |

使用 [Bridge](https://docs.docker.com/network/drivers/bridge) 网络会遇到 qBittorrent 连接性问题，jellyfin DLNA 会有问题，并且 ipv6 开启比较麻烦

使用 [Macvlan](https://docs.docker.com/network/drivers/macvlan) 可以解决网络问题，但无法与宿主通讯

### 安装脚本

使用 git 拉取本仓库

```bash
git clone https://github.com/empty-233/auto-animation.git
```

cd 进入项目文件夹

```bash
cd ./auto-animation
```

赋予脚本执行权限

```bash
chmod +x ./install.sh
```

使用root权限执行(自动判断是否安装docker，没有则安装)

```bash
sudo ./install.sh
```

接着按照脚本说明操作

### docker compose 部署

~~基础操作就不重复了，不会就使用脚本一键安装吧~~

#### Bridge 网络

修改 `docker-compose.yml` 中的 `volumes` 挂载路径

请将 `/Downloads` 修改成你的媒体路径，所有资源都会存放在这个文件夹中

```bash
docker compose up -d
```

#### Macvlan 网络

复制 `example/macvlan.yml` 到根目录替换 `docker-compose.yml`

修改 `docker-compose.yml` 中的 `volumes` 挂载路径

请将 `/Downloads` 修改成你的媒体路径，所有资源都会存放在这个文件夹中

* 修改 `parent` 成你的 `网络接口`
* 修改 `subnet` 成你的 `网络地址段`
* 修改 `gateway` 成你的 `网络网关地址`
* 修改**每个**容器的 `ipv4_address` 成你想要的 `网络地址` (注意，**不能重复，不能已现有的ip地址重复**)

```bash
docker compose up -d
```

### 更新容器

```bash
docker compose down && docker compose pull && docker compose up -d
```

## 容器介绍与注意事项

### Jellyfin

> The Free Software Media System

默认是没有配置硬件加速，如需配置，请前往 [官方教程](https://jellyfin.org/docs/general/administration/hardware-acceleration)

### qBittorrent

> The qBittorrent project aims to provide an open-source software alternative to µTorrent.
>
> Additionally, qBittorrent runs and provides the same features on all major platforms (FreeBSD, Linux, macOS, OS/2, Windows).

注意防火墙连通性，建议使用 Macvlan 网络或者 Host 网络

默认监听 `6881 tcp/udp`

使用的是 `johngong/qbittorrent` ，并且默认使用 qBittorrent-EE

~~"人人为我 我为人人"，能做种就尽量做种吧，为了 BitTorrent 网络的发展，默认是带了 `peerbanhelper` 防止吸血~~

### flaresolverr & prowlarr & sonarr & radarr & jellyseerr & jproxy

> Sonarr is an internet PVR for Usenet and Torrents

这几个容器是为了抓取资源

* `flaresolverr` 是绕过 Cloudflare 保护，防止5秒盾(可选)
* `prowlarr` 是索引器管理，`jproxy`是介于 `Prowlarr` 之间的代理，主要用于优化查询和提升识别率
* `sonarr` 和 `radarr` 是抓取和管理工具，前者是用于电视剧/番剧，后者是用于电影
* `jellyseerr`是用于管理 `jellyfin` 和 `sonarr` 还有 `radarr` 媒体库的请求，提供便捷抓取

### chinesesubfinder(可选)

> 自动化中文字幕下载。字幕网站支持 shooter、xunlei、arrst、a4k、SubtitleBest 。支持 Emby、Jellyfin、Plex、Sonarr、Radarr、TMM

~~一般情况下是用不到的，配置完成抓取的资源一般都是带字幕~~

### peerbanhelper(可选)

> 自动封禁不受欢迎、吸血和异常的 BT 客户端，并支持自定义规则。PeerId黑名单/UserAgent黑名单/IP CIDR/假进度/超量下载/进度回退/多播追猎/连锁封禁/伪装检测 支持 qBittorrent/Transmission/Deluge/BiglyBT/Vuze(Azureus)

BitTorrent 网络已经出现[吸血鬼](https://github.com/anacrolix/torrent/discussions/891)，使用 `peerbanhelper` 自动封禁

~~强烈建议使用，或者使用[qBittorrent-ClientBlocker](https://github.com/Simple-Tracker/qBittorrent-ClientBlocker)，不然pcdn吸血鬼用户分分钟吃满上传~~
