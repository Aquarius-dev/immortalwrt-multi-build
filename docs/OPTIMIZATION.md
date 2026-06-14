# ImmortalWrt Multi-Build 项目架构

## 架构概述

本项目使用 **三个独立 workflow + 一个可复用模板** 的架构，而非 Matrix 策略。

### 为什么选择独立 workflow？

- **构建隔离**：每个设备独立运行，失败不影响其他设备
- **配置灵活**：不同设备可使用不同的 config_method（multi-file / single-file）
- **发布可控**：release.yml 在单个设备完成时触发，收集所有构件

### 工作流文件

| 文件 | 用途 |
|------|------|
| `build-template.yml` | 可复用的构建模板，被三个设备 workflow 调用 |
| `rockchip.yml` | R2S 构建（multi-file 配置） |
| `ramips-r4a.yml` | Xiaomi R4A 构建（single-file + DTS 补丁） |
| `ramips-k2p.yml` | Phicomm K2P 构建（single-file 配置） |
| `release.yml` | 统一发布，自动清理旧版本 |

### 定时构建

所有设备在每月 1 号错开时间触发：

| 设备 | 触发时间 (UTC) |
|------|---------------|
| R2S | 00:00 |
| R4A | 02:00 |
| K2P | 04:00 |

### 配置方式

两种 config_method：

1. **multi-file**（R2S）：合并 `rockchip.config` + `extra.config` + `r2s.config`
2. **single-file**（R4A, K2P）：使用 target/profile 自动生成配置 + 设备特定 config + 最小化裁剪

## 目录结构

```
.github/workflows/
  build-template.yml   # 构建模板 (可复用)
  rockchip.yml         # R2S 触发
  ramips-r4a.yml       # R4A 触发
  ramips-k2p.yml       # K2P 触发
  release.yml          # 统一发布

config/
  extra.config         # 全局配置 （R2S 使用）
  rockchip.config      # rockchip 平台配置
  xiaomi-r4a.config    # R4A 软件包配置
  phicomm-k2p.config   # K2P 软件包配置

patches/
  ramips/              # R4A DTS 分区布局补丁（BREED 兼容）
```

## 添加新设备

1. 创建 `config/<device>.config`（设备软件包配置）
2. 创建 `.github/workflows/<platform>.yml`（构建触发工作流，引用 build-template.yml）
3. 在 `release.yml` 的 `workflows` 列表中添加新 workflow 名称

## 构建流程

```
Checkout source
  -> Checkout repo-config
  -> Apply device-specific patches（R4A DTS 补丁）
  -> Install dependencies
  -> Configure feeds
  -> Configure firmware（multi-file or single-file）
  -> Customize system (UCI defaults, banner)
  -> Download packages
  -> Build
  -> Upload artifacts
```
