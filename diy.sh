#!/bin/bash
# ============================================================
# 在 ImmortalWrt 源码树里做本地定制。
# 由 CI 在 `feeds update` 之前调用：这里要做的事会影响 feed 索引，
# 所以顺序是 ① 改默认值 ② 加 feed ③ 放独立包，最后才 feeds update/install。
# 也可以本地跑：把 immortalwrt 源码放在本仓库同级目录，然后 ./diy.sh
# ============================================================
set -euo pipefail

SRC="immortalwrt"

if [ ! -d "$SRC" ]; then
    echo "错误：找不到 $SRC 目录，请先把 ImmortalWrt 源码 clone 到本仓库根目录下" >&2
    exit 1
fi

echo "==> 1/3 修改默认 LAN IP 与主机名"
CFG_GEN="$SRC/package/base-files/files/bin/config_generate"
if [ ! -f "$CFG_GEN" ]; then
    echo "错误：找不到 $CFG_GEN，源码结构可能变了" >&2
    exit 1
fi

# 默认 LAN IP：192.168.1.1 -> 192.168.10.1
if grep -q '192\.168\.1\.1' "$CFG_GEN"; then
    sed -i 's/192\.168\.1\.1/192.168.10.1/g' "$CFG_GEN"
else
    echo "警告：config_generate 里没找到 192.168.1.1，默认 IP 未改动" >&2
fi

# 默认主机名：ImmortalWrt -> 5G-QModem
if grep -q 'ImmortalWrt' "$CFG_GEN"; then
    sed -i 's/ImmortalWrt/5G-QModem/g' "$CFG_GEN"
else
    echo "警告：config_generate 里没找到 ImmortalWrt，默认主机名未改动" >&2
fi

echo "    当前值："
grep -nE "192\.168\.10\.1|5G-QModem" "$CFG_GEN" | head -n 5 | sed 's/^/    /'

echo "==> 2/3 加入 QModem feed"
# QModem 是 feed（含 luci/ 与 application/ 多个包），官方安装方式就是挂 feed，
# 直接 git clone 到 package/ 下不会被正确索引。
if ! grep -qE '^[[:space:]]*src-git[[:space:]]+qmodem[[:space:]]' "$SRC/feeds.conf.default"; then
    echo 'src-git qmodem https://github.com/ChenLing93/QModem.git;main' >> "$SRC/feeds.conf.default"
    echo "    已写入 feeds.conf.default"
else
    echo "    feeds.conf.default 里已有 qmodem，跳过"
fi
grep -n 'qmodem' "$SRC/feeds.conf.default" | sed 's/^/    /'

echo "==> 3/3 拉取 Aurora 主题（独立 LuCI 包，放进 package/）"
if [ -d "$SRC/package/luci-theme-aurora" ]; then
    echo "    已存在 package/luci-theme-aurora，跳过"
else
    git clone --depth=1 https://github.com/ChenLing93/luci-theme-aurora.git "$SRC/package/luci-theme-aurora"
fi

echo "==> diy.sh 执行完成"
