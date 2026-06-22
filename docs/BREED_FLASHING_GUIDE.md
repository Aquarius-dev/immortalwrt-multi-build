## Xiaomi R4A BREED 直刷问题修复指南

### 问题描述

Xiaomi Mi Router 4A Gigabit 使用 BREED bootloader 直刷固件时，ImmortalWrt 上游固件会出现无限重启。原因是上游的分区布局引入了额外分区（Bdata、crash、cfg_bak、overlay），将 firmware 分区偏移推到了 `0x180000`，而 BREED 内部的分区表预期 firmware 在 `0x50000`。

### 解决方案

#### 核心原因

BREED 内部固化分区表：
| 分区 | 偏移 | 大小 |
|------|------|------|
| u-boot | 0x000000 | 0x30000 |
| u-boot-env | 0x030000 | 0x10000 |
| factory | 0x040000 | 0x10000 |
| **firmware** | **0x050000** | **0xfb0000** |

上游 ImmortalWrt 分区表：
| 分区 | 偏移 | 大小 |
|------|------|------|
| u-boot | 0x000000 | 0x30000 |
| u-boot-env | 0x030000 | 0x10000 |
| Bdata | 0x040000 | 0x10000 |
| factory | 0x050000 | 0x10000 |
| crash | 0x060000 | 0x10000 |
| cfg_bak | 0x070000 | 0x10000 |
| overlay | 0x080000 | 0x100000 |
| **firmware** | **0x180000** | **0xe80000** |

当 BREED 将固件写入 `0x050000`，但内核从 `0x180000` 读取时，启动失败。

#### 修复方式（补丁方案）

本项目通过 **DTS 补丁** 修复此问题，修改 `mt7621_xiaomi_mi-router-4a-common.dtsi`：

- 删除 `Bdata`、`crash`、`cfg_bak`、`overlay` 分区
- `factory` 分区合并到 `partition@40000`
- `firmware` 分区改为 `0x50000` 起始，大小 `0xfb0000` (16064k)

补丁位于 `patches/ramips/0001-*partition*.patch`，构建 R4A 时自动应用。

### 刷机步骤

#### BREED 网页上传（推荐）

1. **进入 BREED**
   - 路由器断电，按住 Reset 按钮
   - 通电不放（持续 5-10 秒）
   - 看到指示灯快闪 -> 释放按钮

2. **连接 BREED**
   - 浏览器访问 `http://192.168.1.1`

3. **上传固件**
   - 进入"固件更新"
   - 选择编译出的 `squashfs-sysupgrade.bin` 文件
   - 勾选"不检查固件版本"
   - 点击"升级"

4. **等待完成**
   - 不要断电，等待指示灯停止闪烁（约 2-5 分钟）

### 固件文件说明

编译完成后，主要使用 `squashfs-sysupgrade.bin` 文件（完整固件，包含内核和文件系统）。

### 验证补丁是否生效

构建日志中可检查：

```
[APPLY] patches/ramips/0001-ramips-mt7621-xiaomi-r4a-breed-compatible-partitions.patch
```

### 常见问题

#### Q: 刷机后无法启动
- 重新进入 BREED
- 刷回官方固件恢复
- 重新刷入新固件

#### Q: BREED 无法识别固件
- 确保使用的是 `.bin` 文件
- 勾选"不检查固件版本"

### 相关资源

- [BREED 官方文档](https://www.right.com.cn/forum/thread-4030501-1-1.html)
- 参考实现: [Plutonium141/XiaoMi-R4A-Gigabit-Actions-OpenWrt](https://github.com/Plutonium141/XiaoMi-R4A-Gigabit-Actions-OpenWrt)
