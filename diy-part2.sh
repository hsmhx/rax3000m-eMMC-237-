#!/bin/bash
#=================================================
# DIY 脚本第二部分：在安装 feeds 之后、编译之前执行
#=================================================

# 1. 使用官方预配置（MT7981 = RAX3000M）
cp -f defconfig/mt7981-ax3000.config .config

# 2. 删除 qmodem 的 ndisc6/rdisc6 问题包
rm -rf feeds/qmodem/application/ndisc6
rm -rf feeds/qmodem/application/rdisc6
rm -f feeds/qmodem/application/ndisc6/patches/100-favor_bsd.patch 2>/dev/null

# 3. 取消有问题的包
sed -i 's/CONFIG_PACKAGE_nginx=y/# CONFIG_PACKAGE_nginx is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_fibocom_QMI_WWAN=y/# CONFIG_PACKAGE_fibocom_QMI_WWAN is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_alist=y/# CONFIG_PACKAGE_alist is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_openlist=y/# CONFIG_PACKAGE_openlist is not set/' .config 2>/dev/null

# 4. 添加必选插件
cat >> .config <<EOF
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-qmodem=y
CONFIG_PACKAGE_qmodem=y
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-serial-option=y
EOF

# 5. 重新生成默认配置
make defconfig

echo "===== DIY 第二部分完成 ====="
echo "===== 目标平台 ====="
grep "CONFIG_TARGET_" .config | head -5
