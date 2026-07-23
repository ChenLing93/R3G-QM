#!/bin/bash

# 进入 ImmortalWrt 源码目录
cd immortalwrt

# 1. 修改默认 LAN IP 为 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名
sed -i 's/ImmortalWrt/5G-QModem/g' package/base-files/files/bin/config_generate


# ==========================================
# 1. 拉取第三方插件 (Git 获取)
# ==========================================
echo "开始拉取第三方插件..."

# 拉取 Aurora 主题 (--depth=1 表示只拉取最新提交，节省时间)
git clone --depth=1 https://github.com/ChenLing93/luci-theme-aurora.git package/luci-theme-aurora

# 拉取 QModem 5G 模组管理
git clone --depth=1 https://github.com/ChenLing93/QModem.git package/QModem

echo "插件拉取完成！"




