# RAX3000M eMMC ImmortalWrt 云编译

基于 237 大佬源码（padavanonly/immortalwrt-mt798x-24.10）的 GitHub Actions 自动编译方案。

## 功能

- 每天自动检测源码更新，有更新则自动编译
- 编译成功后自动上传到 GitHub Releases
- 编译结果通过邮件通知（GitHub 自带）
- 包含插件：qmodem、iStore、磁盘管理、argon 主题、手机 USB 共享、MTK 硬件加速

## 文件说明

```
rax3000m-builder/
├── .github/workflows/build.yml    # 主编译流程
├── diy-part1.sh                   # 编译前修复（feeds、补丁、工具链接）
├── diy-part2.sh                   # 编译后处理（可选）
├── files/
│   └── etc/
│       ├── rc.local               # uhttpd 启动修复
│       ├── config/uhttpd          # uhttpd 配置（无 https 重定向）
│       └── opkg/distfeeds.conf    # 清华源
├── .config                        # 编译配置（需要替换为你本地导出的）
└── README.md
```

## 使用步骤

### 1. 导出本地配置

在 Ubuntu 中执行：

```bash
cd ~/immortalwrt-mt798x-24.10
./scripts/diffconfig.sh > my.config
cat my.config
```

把输出的内容复制，替换本仓库的 `.config` 文件。

### 2. 创建 GitHub 仓库

1. 打开 https://github.com/new
2. 仓库名：`rax3000m-builder`
3. 选 **Public**（公开，Actions 免费）
4. 点 **Create repository**

### 3. 上传文件

把本文件夹的所有文件上传到 GitHub 仓库（保持目录结构）。

### 4. 触发第一次编译

1. 进入仓库的 **Actions** 标签页
2. 左边选 **Build ImmortalWrt for RAX3000M**
3. 点 **Run workflow** → 选 main 分支 → 点 **Run workflow**
4. 等待编译完成（大约 2-4 小时）

### 5. 下载固件

编译成功后，进入仓库的 **Releases** 标签页下载：
- `*-sysupgrade.bin` — 主固件（刷机用）
- `*-initramfs-kernel.bin` — 救援内核
- `mt7981-*.bin` — 预加载器

## 自动更新原理

- 每天北京时间 8:00 自动运行
- 对比源码最新 commit 和上次 Release 的 tag
- 有更新 → 自动编译 → 上传 Releases → 发邮件通知
- 无更新 → 跳过

## 常见问题

### 编译失败怎么办？

1. 进入 Actions → 点击失败的运行 → 查看日志
2. 找到第一个 `ERROR:` 行
3. 根据错误信息修复 `diy-part1.sh` 或 `.config`

### 想手动触发编译？

Actions → Build ImmortalWrt for RAX3000M → Run workflow

### 想修改插件？

修改 `.config` 文件，或者在本地 `make menuconfig` 后重新导出配置。
