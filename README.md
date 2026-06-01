# ImmortalWrt Multi-Build

> :rocket: 使用 GitHub Actions 自动编译 ImmortalWrt 固件，支持三款设备一键构建

---

## :package: 支持的设备

| 设备 | 目标 | 架构 | 固件 |
|------|------|------|------|
| :computer: FriendlyARM NanoPi **R2S** | `rockchip/armv8` | :chip: ARM64 | `immortalwrt-rockchip-armv8-friendlyarm_nanopi-r2s` |
| :signal_strength: Xiaomi Mi Router **4A Gigabit** | `ramips/mt7621` | :chip: MIPS | `immortalwrt-ramips-mt7621-xiaomi_mi-router-4a-gigabit` |
| :moyai: Phicomm **K2P** | `ramips/mt7621` | :chip: MIPS | `immortalwrt-ramips-mt7621-phicomm_k2p` |

---

## :play_or_pause_button: 使用方式

1. :busts_in_silhouette: 进入仓库 **Actions** 标签页
2. :point_right: 选择 **Build ImmortalWrt Firmware**
3. :white_check_mark: 点击 **Run workflow** → **Run workflow**
4. :hourglass_flowing_sand: 等待构建完成（约 **2–5 小时**）
5. :inbox_tray: 在运行结果页面下载 Artifacts 中的固件

> :bulb: 由于完整编译耗时较长，建议在睡前或出门前触发构建。

## :repeat: 自动触发

推送到 `main` 或 `master` 分支时会自动触发构建。每次提交将同时编译三个设备的固件。

---

## :wrench: 自定义软件包

编辑 `.github/workflows/build.yml`，在 **Configure firmware** 步骤中添加需要的软件包：

```yaml
echo "CONFIG_PACKAGE_luci=y" >> .config
echo "CONFIG_PACKAGE_v2ray-core=y" >> .config
echo "CONFIG_PACKAGE_luci-app-passwall=y" >> .config
```

常见软件包参考：
- :globe_with_meridians: **luci** — Web 管理界面
- :lock: **luci-ssl** — HTTPS 访问
- :satellite: **luci-app-passwall** / **luci-app-ssr-plus** — 代理相关
- :file_folder: **luci-app-filetransfer** — 文件传输

---

## :computer: 本地构建

如果你有一台 Linux 机器，也可以在本地编译：

```bash
git clone https://github.com/immortalwrt/immortalwrt --branch openwrt-24.10
cd immortalwrt
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig  # 选择目标设备
make download -j8
make -j$(nproc) V=s
```

---

## :link: 相关链接

- :octocat: [ImmortalWrt 官方仓库](https://github.com/immortalwrt/immortalwrt)
- :globe_with_meridians: [ImmortalWrt 官方网站](https://immortalwrt.org)
- :book: [OpenWrt 构建文档](https://openwrt.org/docs/guide-developer/build-system)

---

## :scroll: License

ImmortalWrt 基于 GPL-2.0 协议开源。
