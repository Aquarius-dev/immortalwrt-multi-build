# Multi-Device Separate Workflows - Design Spec

## 目标
将当前单 `build.yml` matrix 三设备拆分为三个独立 workflow，
并通过可复用 workflow + 独立 release workflow 统一管理。

## 文件结构
```
.github/workflows/
├── build-template.yml        # 可复用构建 (workflow_call)
├── rockchip.yml              # R2S: 调用 build-template
├── ramips-r4a.yml            # Xiaomi R4A: 调用 build-template
├── ramips-k2p.yml            # Phicomm K2P: 调用 build-template
└── release.yml               # 统一 Release (workflow_run)
```

## build-template.yml
**workflow_call 参数:**
- `device_name` (string, required): r2s / xiaomi-r4a / phicomm-k2p
- `target` (string, required): rockchip / ramips
- `subtarget` (string, required): armv8 / mt7621
- `profile` (string, required): device profile
- `lan_ip` (string, required): 192.168.123.x
- `config_method` (string, required): multi-file / single-file

**Jobs:**
- `build`:
  1. Maximize build space
  2. Checkout immortalwrt/immortalwrt (master)
  3. Checkout repo-config
  4. Install build deps
  5. Configure ccache
  6. Cache downloads (dl/)
  7. Cache ccache
  8. Add custom feeds (kenzok8)
  9. Update & install feeds
  10. **Configure firmware** (按 config_method 分支):
      - multi-file: concat rockchip.config + extra.config + r2s.config
      - single-file: 设置 target + make defconfig + 叠加 config + minimization
  11. Customize system config (IP/theme/timezone in uci-defaults)
  12. Customize banner (device info)
  13. Download source packages
  14. Build firmware
  15. Upload firmware to artifact
  16. Upload logs on failure

## 设备 workflow 文件
三个文件各 10-15 行，格式统一：
```yaml
name: rockchip
on:
  schedule:
    - cron: '0 0 1 * *'
  workflow_dispatch:
jobs:
  build:
    uses: ./.github/workflows/build-template.yml
    with:
      device_name: r2s
      target: rockchip
      subtarget: armv8
      profile: friendlyarm_nanopi_r2s
      lan_ip: 192.168.123.2
      config_method: multi-file
```

## release.yml
**触发器:**
- `workflow_run`: 监听三个 workflow 的 `completed` + `success`
- `workflow_dispatch`: 手动

**步骤:**
1. checkout
2. 确定 batch ID（日期 `YYYYMMDD`）
3. 下载 artifact
4. 检查 Release 是否已存在 → 创建或追加
5. tag 命名: `build-<batch_id>`
6. 旧 release 清理: 保留最近 3 个 batch

## 删除
- `.github/workflows/build.yml`
- README.md 更新 workflow badge

## 边界情况
- 设备构建失败: 不影响其他设备，release 只包含成功的固件
- 多 workflow 同时追加: gh CLI 顺序执行，无冲突风险
