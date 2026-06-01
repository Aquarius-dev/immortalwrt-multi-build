# ImmortalWrt Multi-Build

> :rocket: 使用 GitHub Actions 自动编译 ImmortalWrt 固件，支持三款设备一键构建

---

## :package: 支持的设备

| 设备 | 目标 | 架构 | 固件 |
|------|------|------|------|
| :computer: FriendlyARM NanoPi **R2S** | `rockchip/armv8` | ARM64 | `immortalwrt-rockchip-armv8-friendlyarm_nanopi-r2s` |
| :signal_strength: Xiaomi Mi Router **4A Gigabit** | `ramips/mt7621` | MIPS | `immortalwrt-ramips-mt7621-xiaomi_mi-router-4a-gigabit` |
| :moyai: Phicomm **K2P** | `ramips/mt7621` | MIPS | `immortalwrt-ramips-mt7621-phicomm_k2p` |

---

## :play_or_pause_button: 使用方式

1. :busts_in_silhouette: 进入仓库 **Actions** 标签页
2. :point_right: 选择 **Build ImmortalWrt Firmware**
3. :white_check_mark: 点击 **Run workflow** → **Run workflow**
4. :hourglass_flowing_sand: 等待构建完成（约 **2–5 小时**）
5. :inbox_tray: 在运行结果页面下载 Artifacts 中的固件

> :bulb: 由于完整编译耗时较长，建议在睡前或出门前触发构建。

## :repeat: 构建方式

- **定时触发**：每月 1 号零点自动构建
- **手动触发**：在 Actions 页面点击 **Run workflow**

---

## :wrench: 自定义软件包

### 方式一：config 文件管理（推荐）

在 `config/` 目录下有各设备的配置文件，直接编辑即可：

```
config/
├── r2s.config
├── xiaomi-r4a.config
└── phicomm-k2p.config
```

例如添加 `passwall`：

```bash
echo "CONFIG_PACKAGE_luci-app-passwall=y" >> config/r2s.config
```

### 方式二：本地生成配置

在 Linux 机器上运行 `make menuconfig` 选择需要的软件包，然后将生成的 `.config` 覆盖到 `config/<设备>.config`：

```bash
git clone https://github.com/immortalwrt/immortalwrt --branch master
cd immortalwrt
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig              # 选择设备 + 软件包
cp .config ../config/r2s.config   # 保存配置到仓库
```

然后提交推送即可。

### 常见软件包参考

| 软件包 | 说明 |
|--------|------|
| `luci` | Web 管理界面 |
| `luci-ssl` | HTTPS 访问 |
| `luci-theme-material` | Material 主题（已内置） |
| `luci-app-passwall` | 代理 |
| `luci-app-openclash` | 代理 |
| `luci-app-ssr-plus` | 代理 |
| `luci-app-upnp` | UPnP 端口映射 |
| `luci-app-wireguard` | WireGuard VPN |
| `luci-app-ttyd` | 网页终端 |
| `luci-app-filetransfer` | 文件传输 |

---

## :link: 相关链接

- :octocat: [ImmortalWrt 官方仓库](https://github.com/immortalwrt/immortalwrt)
- :globe_with_meridians: [ImmortalWrt 官方网站](https://immortalwrt.org)
- :book: [OpenWrt 构建文档](https://openwrt.org/docs/guide-developer/build-system)

---

## :scroll: License

ImmortalWrt 基于 GPL-2.0 协议开源。
