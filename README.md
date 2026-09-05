# RAX3000M ImmortalWrt 自动编译

基于 GitHub Actions 的 CMCC RAX3000M eMMC 路由器 ImmortalWrt 固件自动编译项目。

## 功能特性

- 每天自动检测源码更新，有更新则自动编译
- 编译完成自动上传到 GitHub Releases
- 同步上传到 123 网盘
- 内置 qmodem、iStore、磁盘管理、argon 主题、USB共享、MTK加速
- 默认清华软件源，关闭 https 重定向

## 固件信息

| 项目 | 内容 |
|---|---|
| 源码 | padavanonly/immortalwrt-mt798x-24.10 |
| 分支 | openwrt-24.10-6.6 |
| 平台 | MediaTek MT7981 (filogic) |
| 设备 | CMCC RAX3000M eMMC |
| 架构 | aarch64_cortex-a53 |

## 包含插件

- qmodem（5G模块管理）
- iStore（应用商店）
- 磁盘管理（luci-app-diskman + cfdisk + lsblk）
- argon 主题
- 手机 USB 网络共享（rndis + cdc-ncm）
- MTK 硬件加速（HNAT + PPE + WED）
- LuCI 中文界面

## 快速开始

### 第 1 步：Fork 本仓库

点击右上角 `Fork` 按钮，复制到你自己的 GitHub 账号下。

### 第 2 步：配置 123 网盘 Secrets

1. 进入你 Fork 的仓库 → `Settings` → `Secrets and variables` → `Actions`
2. 点击 `New repository secret`
3. 添加以下两个 Secret：

| Name | Value |
|---|---|
| `PAN123_USERNAME` | 你的 123 网盘账号（手机号/邮箱） |
| `PAN123_PASSWORD` | 你的 123 网盘密码 |

> GitHub Token 不需要手动配置，Actions 会自动提供。

### 第 3 步：手动触发第一次编译

1. 进入仓库 → `Actions` → 选择 `RAX3000M ImmortalWrt 自动编译`
2. 点击 `Run workflow` → 选择 `main` 分支 → 点击 `Run workflow`
3. 等待编译完成（约 2～4 小时）

### 第 4 步：获取固件

编译完成后：
- **GitHub Releases**：进入仓库首页 → 右侧 `Releases` → 下载最新版本
- **123 网盘**：登录 123 网盘 → `RAX3000M-ImmortalWrt` 文件夹 → 按日期分类

## 自动编译说明

- **触发时间**：每天北京时间早上 8:00（UTC 0:00）
- **编译条件**：检测到上游源码有新提交才会编译
- **无更新时**：跳过编译，不浪费 Actions 时间
- **手动触发**：随时可以在 Actions 页面点击 `Run workflow`

## 目录结构

```
rax3000m-builder/
├── .github/
│   └── workflows/
│       └── build.yml          # 主编译工作流
├── files/
│   └── etc/
│       ├── config/
│       │   └── uhttpd         # 关闭 https 重定向
│       └── opkg/
│           └── distfeeds.conf # 清华软件源
├── diy-part1.sh               # 编译前脚本（添加feeds）
├── diy-part2.sh               # 编译前脚本（修bug、选包）
├── .config                    # 基础编译配置
└── README.md                  # 本文件
```

## 自定义配置

### 修改编译配置

编辑 `.config` 文件，或在 `diy-part2.sh` 中添加/取消包：

```bash
# 添加包
echo "CONFIG_PACKAGE_xxx=y" >> .config

# 取消包
sed -i 's/CONFIG_PACKAGE_xxx=y/# CONFIG_PACKAGE_xxx is not set/' .config
```

### 修改源码地址

编辑 `.github/workflows/build.yml` 中的环境变量：

```yaml
env:
  REPO_URL: https://github.com/你的源码地址.git
  REPO_BRANCH: 你的分支
```

### 修改编译时间

编辑 `.github/workflows/build.yml` 中的 cron 表达式：

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # UTC 0:00 = 北京时间 8:00
```

## 常见问题

### Q: 编译失败怎么办？

A: 进入 Actions → 点击失败的任务 → 查看日志，找到报错信息。常见问题：
- 内存不足：Actions 有 7GB 内存，一般够用
- 下载超时：已配置 goproxy.cn 和清华源
- 包编译失败：在 diy-part2.sh 中取消该包

### Q: 123 网盘上传失败？

A: 检查 Secrets 中的账号密码是否正确，123 网盘是否有足够空间。

### Q: 如何只编译不上传？

A: 手动触发时，将 `skip_build` 设为 `true` 可以跳过编译测试环境。

### Q: 固件刷不进去？

A: 确认下载的是 `*sysupgrade*` 文件，先刷第三方 U-Boot，再通过 U-Boot 网页界面刷入。

## 刷机说明

1. 路由器断电，按住 Reset 键不松手
2. 插电，等待绿灯闪烁后松开
3. 电脑设静态 IP `192.168.1.2`，访问 `http://192.168.1.1`
4. 上传 `*-sysupgrade.bin`，等待刷写完成
5. 电脑改回自动获取 IP，访问 `http://192.168.1.1`

## 免责声明

本项目仅供学习交流使用，刷机有风险，操作需谨慎。因刷机造成的任何损失，本项目概不负责。
