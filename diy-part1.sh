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

# 2. 跳过 237 源码的 prereq 检查 bug
mkdir -p staging_dir/host
touch staging_dir/host/.prereq-build

# 3. 删除 qmodem 的问题包（ndisc6 递归依赖 + 补丁失败）
rm -rf feeds/qmodem/application/ndisc6
rm -rf feeds/qmodem/application/rdisc6

echo "===== DIY 第一部分完成 ====="
