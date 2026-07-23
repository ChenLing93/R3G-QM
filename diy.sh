#!/bin/bash

# 进入 ImmortalWrt 源码目录
cd immortalwrt

# 1. 修改默认 LAN IP 为 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名
sed -i 's/ImmortalWrt/5G-QModem/g' package/base-files/files/bin/config_generate

