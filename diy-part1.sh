#!/bin/bash
#=================================================
# DIY 第一部分：编译前修复
#=================================================

echo "===== 开始 DIY 第一部分 ====="

# 1. 添加第三方 feeds
cat >> feeds.conf.default << 'EOF'
src-git qmodem https://github.com/FUjr/QModem.git
src-git istore https://github.com/linkease/istore.git
src-git nas https://github.com/linkease/nas-packages.git
EOF

# 2. 跳过 237 源码的 prereq 检查 bug
mkdir -p staging_dir/host
touch staging_dir/host/.prereq-build

# 3. 创建 mkhash wrapper（237 源码构建顺序 bug，feeds update 阶段就需要）
mkdir -p staging_dir/host/bin
cat > staging_dir/host/bin/mkhash << 'MKEOF'
#!/bin/bash
if [ "$1" = "sha256" ]; then
    shift
    if [ -n "$1" ]; then sha256sum "$@" 2>/dev/null | awk '{print $1}'; else sha256sum 2>/dev/null | awk '{print $1}'; fi
elif [ "$1" = "md5" ]; then
    shift
    if [ -n "$1" ]; then md5sum "$@" 2>/dev/null | awk '{print $1}'; else md5sum 2>/dev/null | awk '{print $1}'; fi
fi
MKEOF
chmod +x staging_dir/host/bin/mkhash

# 4. 链接系统工具到 staging_dir/host/bin（237 源码构建顺序 bug）
for tool in bash sh env gzip tar xz bzip2 cpio awk sed grep find gcc cc g++ cpp ld as ar ranlib nm strip objcopy objdump make cmake python3 perl install ln cp mv rm mkdir chmod chown cat echo; do
    [ -x "$(which $tool 2>/dev/null)" ] && [ ! -f "staging_dir/host/bin/$tool" ] && ln -sf "$(which $tool)" "staging_dir/host/bin/$tool"
done

# 5. 删除 ndisc6 问题补丁（不删除包本身，否则 qmodem 依赖缺失）
rm -f feeds/qmodem/application/ndisc6/patches/100-favor_bsd.patch

# 6. 修复 5g-modem 驱动（内核函数改名 + 去掉 -Werror）
if [ -d "package/mtk/applications/5g-modem" ]; then
    find package/mtk/applications/5g-modem -name "*.c" -exec sed -i 's/u64_stats_fetch_begin_irq/u64_stats_fetch_begin/g' {} \;
    find package/mtk/applications/5g-modem -name "*.c" -exec sed -i 's/u64_stats_fetch_retry_irq/u64_stats_fetch_retry/g' {} \;
    find package/mtk/applications/5g-modem -type f \( -name "Makefile" -o -name "Kbuild" -o -name "*.mk" \) -exec sed -i 's/-Werror//g' {} \;
fi

# 7. 设置 Go 代理（国内加速）
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=off

echo "===== DIY 第一部分完成 ====="
