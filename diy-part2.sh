#!/bin/bash
#=================================================
# DIY 脚本第二部分：在安装 feeds 之后、编译之前执行
#=================================================

# 1. 使用官方预配置
cp -f defconfig/mt7981-ax3000.config .config

# 2. 修复 5g-modem 驱动在新内核下的编译错误（函数改名）
find package/mtk/applications/5g-modem -name "*.c" -exec sed -i 's/u64_stats_fetch_begin_irq/u64_stats_fetch_begin/g' {} \;
find package/mtk/applications/5g-modem -name "*.c" -exec sed -i 's/u64_stats_fetch_retry_irq/u64_stats_fetch_retry/g' {} \;

# 3. 去掉 5g-modem 驱动的 -Werror
find package/mtk/applications/5g-modem -type f \( -name "Makefile" -o -name "Kbuild" -o -name "*.mk" \) -exec sed -i 's/-Werror//g' {} \;

# 4. 取消 nginx（避免 https 强制重定向）
sed -i 's/CONFIG_PACKAGE_nginx=y/# CONFIG_PACKAGE_nginx is not set/' .config 2>/dev/null

# 5. 添加必选插件
cat >> .config <<EOF
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-qmodem=y
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-serial-option=y
EOF

# 6. 重新生成配置
make defconfig

echo "===== DIY 第二部分完成 ====="
