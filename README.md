# 🏗️ ImmortalWrt Multi-Build

[![R2S](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/rockchip.yml/badge.svg)](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/rockchip.yml)
[![R4A](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/ramips-r4a.yml/badge.svg)](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/ramips-r4a.yml)
[![K2P](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/ramips-k2p.yml/badge.svg)](https://github.com/Aquarius-dev/immortalwrt-multi-build/actions/workflows/ramips-k2p.yml)

> 🚀 基于 GitHub Actions 自动编译 **ImmortalWrt** 固件，支持三款设备一键构建、自动发布 Release。

---

## 📦 支持的设备

| 设备 | 平台 | 架构 | LAN IP |
|------|------|:----:|:------:|
| 🖥️ **NanoPi R2S** | `rockchip/armv8` | ARM64 | `192.168.123.2` |
| 📡 **Xiaomi Mi Router 4A Gigabit** | `ramips/mt7621` | MIPS | `192.168.123.6` |
| 🗿 **Phicomm K2P** | `ramips/mt7621` | MIPS | `192.168.123.5` |

> ℹ️ R4A 和 K2P 为最小化构建，已移除 DHCP、IPv6、USB、PPP 等非必要组件。

---

## 🎮 使用方式

| 方式 | 说明 |
|------|------|
| 📅 **定时构建** | 每月 **1 号 00:00** 自动触发 |
| 👆 **手动构建** | 进入 **Actions** → **Build ImmortalWrt Firmware** → **Run workflow** |
| ⏱ **耗时** | 约 **2~5 小时**（完整源码编译） |
| 📥 **下载** | 构建完成后进入对应 Run → **Artifacts** 或 **Releases** |

> 💡 建议在睡前或出门前触发，回来就能收到固件。

---

## 🛠️ 自定义配置

### 📄 方式一：编辑 config 文件（推荐）

每个设备对应一个配置文件，直接修改后推送即可：

```
config/
├── r2s.config              # R2S 附加软件包
├── xiaomi-r4a.config       # Xiaomi R4A 附加软件包
└── phicomm-k2p.config      # K2P 附加软件包
```

示例 — 添加 passwall：

```bash
echo "CONFIG_PACKAGE_luci-app-passwall=y" >> config/r2s.config
git add config/r2s.config
git commit -m "Add passwall for R2S"
git push
```

### 🖥️ 方式二：本地 `make menuconfig` 生成

```bash
# 拉取源码 → 选择软件包 → 导出配置
git clone https://github.com/immortalwrt/immortalwrt --branch master
cd immortalwrt
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig                      # 选择设备和软件包
cp .config /path/to/config/r2s.config  # 覆盖仓库中的配置
```

### 📋 常用软件包

| 类别 | 软件包 | 用途 |
|------|--------|------|
| 🌐 界面 | `luci` + `luci-ssl` | Web 管理 + HTTPS |
| 🎨 主题 | `luci-theme-material` | Material 主题（已集成） |
| 🚀 代理 | `luci-app-passwall` / `luci-app-openclash` / `luci-app-ssr-plus` | 科学上网 |
| 🔌 网络 | `luci-app-upnp` / `luci-app-sqm` | UPnP / QoS |
| 🔒 VPN | `luci-app-wireguard` / `luci-app-openvpn` | VPN 服务 |
| 🖥️ 工具 | `luci-app-ttyd` / `luci-app-filetransfer` | 网页终端 / 文件传输 |

---

## 🧪 本地构建

```bash
# 完整编译流程
git clone https://github.com/immortalwrt/immortalwrt --branch master
cd immortalwrt
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
make download -j8
make -j$(nproc) V=s
```

---

## 📎 相关链接

- [ImmortalWrt 源码](https://github.com/immortalwrt/immortalwrt)
- [ImmortalWrt 官网](https://immortalwrt.org)
- [OpenWrt 构建文档](https://openwrt.org/docs/guide-developer/build-system)

---

## 📜 License

ImmortalWrt 基于 **GPL-2.0** 协议开源。
