#!/bin/bash
#=================================================
# DIY 脚本第一部分：在更新 feeds 之前执行
#=================================================

# 1. 添加第三方 feeds
cat >> feeds.conf.default <<EOF
src-git qmodem https://github.com/FUjr/QModem.git
src-git istore https://github.com/linkease/istore.git
src-git nas https://github.com/linkease/nas-packages.git
EOF

# 2. 跳过 237 源码的依赖检查 bug
mkdir -p staging_dir/host
touch staging_dir/host/.prereq-build

# 3. 创建 mkhash 替代脚本（修复237源码构建顺序bug）
mkdir -p staging_dir/host/bin
cat > staging_dir/host/bin/mkhash << 'EOF'
#!/bin/bash
if [ "$1" = "sha256" ]; then
    shift
    if [ -n "$1" ]; then
        sha256sum "$@" 2>/dev/null | awk '{print $1}'
    else
        sha256sum 2>/dev/null | awk '{print $1}'
    fi
elif [ "$1" = "md5" ]; then
    shift
    if [ -n "$1" ]; then
        md5sum "$@" 2>/dev/null | awk '{print $1}'
    else
        md5sum 2>/dev/null | awk '{print $1}'
    fi
fi
EOF
chmod +x staging_dir/host/bin/mkhash
echo "mkhash wrapper created"

# 4. 删除有问题的 5g-modem 厂商驱动（代码老旧，和新内核不兼容）
rm -rf package/mtk/applications/5g-modem



echo "===== DIY 第一部分完成 ====="
