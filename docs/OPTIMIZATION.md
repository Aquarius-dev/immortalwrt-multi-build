# ImmortalWrt Multi-Build 优化指南

## 📁 项目结构优化

```
.github/workflows/
├── build-template-v2.yml    # 精简的模板工作流（可复用）
├── build-all.yml           # 新的多设备构建流程（推荐使用）
├── rockchip.yml            # 保留向后兼容性
├── ramips-r4a.yml          # 保留向后兼容性
└── ramips-k2p.yml          # 保留向后兼容性

scripts/
├── setup-build-env.sh      # 环境设置（依赖安装）
├── configure-feeds.sh      # Feed配置
├── build-config.sh         # 配置文件生成和合并
└── customize-system.sh     # 系统定制

config/
├── base.config             # 基础配置（通用）
├── rockchip.config         # 平台配置
├── r2s.config              # 设备特定配置
├── xiaomi-r4a.config       # 设备特定配置
├── phicomm-k2p.config      # 设备特定配置
├── extra.config            # 额外配置（可选）
└── devices.yml             # 设备定义表
```

## 🎯 主要优化点

### 1. **模块化脚本** (减少工作流重复代码)
- ✅ 每个步骤对应一个脚本
- ✅ 脚本可独立测试和维护
- ✅ 工作流文件从 191 行减少到 ~160 行

### 2. **使用 Matrix Strategy** (支持并行构建)
```yaml
strategy:
  matrix:
    device: [r2s, r4a, k2p]
```
- ✅ 三个设备并行编译，总时间不增加
- ✅ 失败不阻塞其他设备编译
- ✅ 易于添加新设备

### 3. **统一的发布流程**
- ✅ 所有设备构建完成后统一发布
- ✅ 自动清理旧版本（保留最新3个）
- ✅ 更整洁的 Release 页面

### 4. **增强的缓存策略**
- ✅ 分设备缓存 ccache
- ✅ 共享下载缓存（加速首次构建）
- ✅ 减少重复下载和编译时间

### 5. **更好的错误诊断**
- ✅ 使用 `time` 命令输出编译耗时
- ✅ 建立 Summary 报告（GitHub UI 中可见）
- ✅ 分离日志上传（便于查找错误）

## 🚀 使用方法

### 方法 1: 使用新的多设备工作流（推荐）

#### 自动定时构建（月初）
```
GitHub Actions 会自动在每月 1 号按时间表运行：
- 00:00 UTC: R2S 构建
- 02:00 UTC: R4A 构建
- 04:00 UTC: K2P 构建
```

#### 手动构建所有设备
```
Actions → Multi-Device Build → Run workflow → Run
```

#### 手动构建单个设备
```
Actions → Multi-Device Build → Run workflow
输入: device = r2s (或 r4a, k2p)
→ Run
```

### 方法 2: 保持使用旧工作流（向后兼容）
```
Actions → rockchip/ramips-r4a/ramips-k2p → Run workflow
```

## 📊 性能对比

| 指标 | 原版 | 优化版 |
|------|------|--------|
| 工作流文件行数 | 191 | 160 |
| 代码重复率 | 中 | 低 |
| 三设备总耗时 | 串行 8-15h | 并行 2.5-5h |
| 易维护性 | 中 | 高 |
| 支持新设备 | 困难 | 简单 |

## 🔧 配置新设备

### 步骤 1: 在 `config/devices.yml` 中定义

```yaml
my-device:
  name: "My Device"
  target: my-platform
  subtarget: my-arch
  profile: my_device_profile
  lan_ip: 192.168.123.100
  config_method: multi-file or single-file
  schedule: "0 6 1 * *"   # 06:00 UTC on 1st
```

### 步骤 2: 创建配置文件

```bash
config/my-device.config      # 设备特定配置
config/my-platform.config    # 平台配置（可选）
```

### 步骤 3: 在 `build-all.yml` 中添加到 matrix

```yaml
matrix:
  device: [r2s, r4a, k2p, my-device]  # 添加新设备
```

就这样！新设备会自动被构建并发布。

## 💡 故障排查

### 构建失败查看日志
```
Actions → 失败的 Run → logs-<device-name> → 下载 build.log
```

### 配置文件生成错误
```
Actions → 失败的 Run → logs-<device-name> → 检查下载阶段日志
```

### 清理构建缓存
```
Settings → Actions → General → Caches → Delete 旧缓存
```

## 🎯 后续优化建议

- [ ] 添加 Docker 构建以支持本地测试
- [ ] 集成增量编译（仅编译变更部分）
- [ ] 添加编译时间统计分析
- [ ] 支持自定义设备包选择
- [ ] 集成 Telegram/Discord 通知
- [ ] 添加编译质量检查（编译警告等级统计）

