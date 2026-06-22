# ImmortalWrt Multi-Build 项目架构

## 架构概述

本项目使用 **Matrix 并行构建策略**，所有设备在一个 workflow 中并行编译。

### 为什么选择 Matrix？

- **构建隔离**：`fail-fast: false` 确保单个设备失败不影响其他设备
- **并行加速**：三设备同时构建，总时间 ≈ 最慢设备（R2S ~5h），而非串行的 10h+
- **配置灵活**：不同设备可有不同的 config_method（multi-file / single-file）
- **发布简化**：release.yml 监听单个 workflow 的完成即可

### 工作流文件

| 文件 | 用途 |
|------|------|
| `build-all.yml` | Matrix 策略，三设备并行构建触发 |
| `build-template.yml` | 可复用的构建模板 |
| `release.yml` | 统一发布，自动清理旧版本 |

### 定时构建

每月 1 号 00:00 UTC 一次性触发，三设备并行：

| 设备 | 超时 |
|------|------|
| R2S | 420 min (完整构建) |
| R4A | 180 min (最小化构建) |
| K2P | 180 min (最小化构建) |

### 配置方式

两种 config_method：

1. **multi-file**（R2S）：合并 `rockchip.config` + `extra.config` + `r2s.config`
2. **single-file**（R4A, K2P）：使用 target/profile 自动生成配置 + `ramips-common.config` + 设备特定 config 叠加 + 最小化裁剪

### 缓存策略

| 缓存 | key 策略 | 目的 |
|------|----------|------|
| `dl/` | `immortalwrt-master-{target}-{subtarget}-dl` | 源码包缓存 |
| `.ccache` | `ccache-{target}-{subtarget}-{device}` + 回退共享 | 同平台（ramips）设备共享编译缓存 |
| `staging_dir/toolchain-*` | `toolchain-{target}-{subtarget}` + hash | 工具链缓存，加速跨月构建 |

## 目录结构

```
.github/workflows/
  build-all.yml         # Matrix 并行构建触发
  build-template.yml    # 构建模板 (可复用)
  release.yml           # 统一发布

config/
  extra.config          # 全局配置（R2S 使用）— 瘦身 82%
  rockchip.config       # rockchip 平台配置
  ramips-common.config  # ramips 设备共享配置
  xiaomi-r4a.config     # R4A 软件包（叠加 ramips-common）
  phicomm-k2p.config    # K2P 软件包（叠加 ramips-common）

patches/
  ramips/               # R4A DTS 分区布局补丁（BREED 兼容）
```

## 添加新设备

1. 创建 `config/<device>.config`（设备软件包配置）
2. 如设备与现有设备同平台，可选创建平台共享配置（如 `ramips-common.config`）
3. 在 `build-all.yml` 的 `matrix.include` 中添加设备参数
4. 如有需要，在 `build-template.yml` 中添加设备专用补丁步骤

## 构建流程

```
Checkout source
  -> Checkout repo-config
  -> Apply device-specific patches（R4A DTS 补丁）
  -> Install dependencies
  -> Configure feeds
  -> Configure firmware（multi-file or single-file）
  -> Customize system (UCI defaults, banner)
  -> Download packages（失败自动重试 3 次）
  -> Build
  -> Upload artifacts
```
