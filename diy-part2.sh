#!/bin/bash
#=================================================
# DIY 脚本第二部分：在安装 feeds 之后、编译之前执行
#=================================================

# 使用官方预配置（MT7981 = RAX3000M）
cp -f defconfig/mt7981-ax3000.config .config

# 1. 删除 qmodem 的 ndisc6/rdisc6 问题包（递归依赖 bug）
rm -rf feeds/qmodem/application/ndisc6
rm -rf feeds/qmodem/application/rdisc6

# 2. 删除 ndisc6 问题补丁
rm -f feeds/qmodem/application/ndisc6/patches/100-favor_bsd.patch 2>/dev/null

# 3. 取消有问题的包（通过修改 .config）
# 取消 nginx（会强制 https 重定向）
sed -i 's/CONFIG_PACKAGE_nginx=y/# CONFIG_PACKAGE_nginx is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_luci-app-nginx=y/# CONFIG_PACKAGE_luci-app-nginx is not set/' .config 2>/dev/null

# 取消 fibocom_QMI_WWAN（编译失败）
sed -i 's/CONFIG_PACKAGE_fibocom_QMI_WWAN=y/# CONFIG_PACKAGE_fibocom_QMI_WWAN is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_kmod-fibocom_QMI_WWAN=y/# CONFIG_PACKAGE_kmod-fibocom_QMI_WWAN is not set/' .config 2>/dev/null

# 取消 alist（fuse 依赖问题，需要可手动开启）
sed -i 's/CONFIG_PACKAGE_luci-app-alist=y/# CONFIG_PACKAGE_luci-app-alist is not set/' .config 2>/dev/null
sed -i 's/CONFIG_PACKAGE_alist=y/# CONFIG_PACKAGE_alist is not set/' .config 2>/dev/null

# 取消 openlist（Go 编译不稳定）
sed -i 's/CONFIG_PACKAGE_openlist=y/# CONFIG_PACKAGE_openlist is not set/' .config 2>/dev/null

# 4. 确保必选包被选中
echo "CONFIG_PACKAGE_luci=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
echo "CONFIG_PACKAGE_luci-app-diskman=y" >> .config
echo "CONFIG_PACKAGE_luci-app-qmodem=y" >> .config
echo "CONFIG_PACKAGE_qmodem=y" >> .config
echo "CONFIG_PACKAGE_cfdisk=y" >> .config
echo "CONFIG_PACKAGE_lsblk=y" >> .config
echo "CONFIG_PACKAGE_blkid=y" >> .config
echo "CONFIG_PACKAGE_e2fsprogs=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-net-rndis=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-serial-option=y" >> .config

# 5. 重新生成默认配置
make defconfig

echo "===== DIY 第二部分完成 ====="
echo "===== 配置摘要 ====="
grep -E "CONFIG_TARGET_|CONFIG_PACKAGE_luci|CONFIG_PACKAGE_qmodem|CONFIG_PACKAGE_istore|CONFIG_PACKAGE_store" .config | head -30
