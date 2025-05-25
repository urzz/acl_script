# CDN 优选脚本使用指南

本目录包含用于 CDN（Cloudflare 和 CloudFront）优选 IP 测试的脚本工具，帮助你在本地网络环境中找到最适合的 CDN IP 地址。

## 📋 脚本列表

| 脚本文件 | 功能描述 | 适用场景 |
|---------|---------|---------|
| `cdn-speedtest.sh` | 完整的 CDN 优选测试脚本 | 需要完整优选时使用 |
| `quick-cdn-test.sh` | 快速验证当前 IP 状态 | 验证现有配置性能 |

## 🚀 功能特点

### cdn-speedtest.sh
- ✅ **双 CDN 支持**：同时优选 Cloudflare 和 CloudFront
- ✅ **本地网络测试**：在你的真实网络环境中测试
- ✅ **自动识别**：自动识别域名使用的 CDN 类型
- ✅ **多种输出格式**：生成分离和合并的配置文件
- ✅ **安全备份**：生成新文件，不覆盖原配置
- ✅ **详细日志**：显示完整的测试过程

### quick-cdn-test.sh
- ⚡ **快速验证**：快速测试当前配置的 IP 性能
- 📊 **延迟检测**：显示 ping 延迟和 HTTP 响应时间
- 🔍 **连通性检查**：验证 IP 的可达性

## 📦 依赖要求

### 必需依赖
- `curl` - HTTP 请求工具
- `wget` - 文件下载工具
- `bc` - 基础计算器（用于数学运算）
- `ping` - 网络连通性测试

### 系统支持
- ✅ Linux (推荐)
- ✅ macOS
- ❌ Windows (需要 WSL 环境)

### 安装依赖

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install curl wget bc iputils-ping
```

**CentOS/RHEL:**
```bash
sudo yum install curl wget bc iputils
```

**macOS:**
```bash
# 通过 Homebrew 安装
brew install curl wget bc

# ping 命令通常已内置
```

## 🛠️ 安装步骤

1. **克隆或下载项目**
```bash
# 如果还没有项目目录，创建它
mkdir -p acl_script/scripts
cd acl_script/scripts
```

2. **创建脚本文件**
```bash
# 下载或创建 cdn-speedtest.sh
# 下载或创建 quick-cdn-test.sh
```

3. **添加执行权限**
```bash
chmod +x *.sh
```

4. **验证环境**
```bash
# 检查依赖是否安装完成
./quick-cdn-test.sh
```

## 📖 使用方法

### 方法一：完整 CDN 优选测试

```bash
# 进入脚本目录
cd scripts

# 运行完整优选测试
./cdn-speedtest.sh
```

**执行过程：**
1. 检查系统依赖
2. 下载 CloudflareSpeedTest 工具
3. 创建 CloudFront IP 测试列表
4. 执行 Cloudflare 优选测试
5. 执行 CloudFront 延迟测试
6. 生成优选配置文件
7. 显示结果和使用建议

### 方法二：快速验证当前配置

```bash
# 进入脚本目录
cd scripts

# 快速测试当前 IP 性能
./quick-cdn-test.sh
```

### 方法三：高级参数配置

如需自定义测试参数，可以修改 `cdn-speedtest.sh` 中的以下变量：

```bash
# 编辑脚本文件
nano cdn-speedtest.sh

# 找到测试参数部分，可调整：
# - 延迟上限：-tl 200 (毫秒)
# - 速度下限：-sl 2.0 (MB/s)  
# - 测试数量：-dn 5 (个数)
```

## 📁 输出文件说明

运行 `cdn-speedtest.sh` 后，会在工作目录生成以下文件：

### 测试结果文件

| 文件名 | 描述 | 用途 |
|-------|------|------|
| `cf_result.csv` | Cloudflare 完整测试结果 | 查看详细测速数据 |
| `cloudfront_results.txt` | CloudFront 延迟测试原始数据 | 调试和分析用 |
| `cloudfront_best.txt` | CloudFront 优选结果（前5个）| 查看最佳 CloudFront IP |

### 配置文件输出

| 文件名 | 描述 | 用途 |
|-------|------|------|
| `hosts_updated.txt` | **[主要文件]** 更新后的完整 hosts 配置 | 直接替换 `../mosdns/hosts.txt` |
| `cf_domain.txt` | Cloudflare 域名配置（独立文件）| 单独管理 Cloudflare 域名 |
| `cloudfront_domain.txt` | CloudFront 域名配置（独立文件）| 单独管理 CloudFront 域名 |
| `cloudfront_ips.txt` | CloudFront IP 测试列表 | 下次测试的 IP 范围 |

### 应用配置

**方式一：完整替换（推荐）**
```bash
# 备份原配置
cp ../mosdns/hosts.txt ../mosdns/hosts.txt.backup

# 应用新配置
cp hosts_updated.txt ../mosdns/hosts.txt
```

**方式二：分别管理**
```bash
# 复制独立配置文件
cp cf_domain.txt ../mosdns/
cp cloudfront_domain.txt ../mosdns/

# 在 mosdns 配置中引用这些文件
```

## 🔧 故障排除

### 常见问题

#### 1. 脚本执行权限不足
```bash
# 解决方法
chmod +x cdn-speedtest.sh quick-cdn-test.sh
```

#### 2. 依赖缺失错误
```bash
# Ubuntu/Debian 用户
sudo apt update && sudo apt install curl wget bc iputils-ping

# CentOS/RHEL 用户  
sudo yum install curl wget bc iputils

# macOS 用户
brew install curl wget bc
```

#### 3. 网络超时或连接失败
```bash
# 检查网络连接
ping 8.8.8.8

# 检查防火墙设置
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-all  # CentOS

# 使用代理（如需要）
export http_proxy=http://proxy:port
export https_proxy=http://proxy:port
```

#### 4. CloudflareSpeedTest 下载失败
```bash
# 手动下载并放置
mkdir -p cdn_speedtest_temp
cd cdn_speedtest_temp
wget https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz
tar -xzf CloudflareST_linux_amd64.tar.gz
chmod +x CloudflareST
```

#### 5. 测试结果为空或异常
- **检查网络环境**：确保能访问外网
- **调整测试参数**：编辑脚本中的 `-tl` (延迟上限) 和 `-sl` (速度下限) 参数
- **更换测试时间**：避开网络繁忙时段

### 测试参数优化

根据你的网络环境调整以下参数：

**网络较慢的环境：**
```bash
# 在 cdn-speedtest.sh 中修改
./CloudflareST -tl 500 -sl 0.5 -dn 10
```

**网络较快的环境：**
```bash
# 在 cdn-speedtest.sh 中修改  
./CloudflareST -tl 100 -sl 5.0 -dn 3
```

## 📊 测试建议

### 最佳测试时间
- ⏰ **推荐时间**：上午 9-11 点，下午 2-5 点
- ❌ **避免时间**：晚上 7-11 点（网络高峰期）

### 测试频率
- 🔄 **定期测试**：每周 1-2 次
- 🚨 **异常时测试**：发现访问慢时立即测试
- 📅 **季节性测试**：每季度做一次全面测试

### 结果验证
测试完成后，建议进行以下验证：

```bash
# 验证新 IP 的连通性
./quick-cdn-test.sh

# 测试实际应用效果（以某个域名为例）
curl -w "@curl-format.txt" -o /dev/null -s "http://your-optimized-domain.com"
```

## 🔄 定期更新

### 自动化脚本（可选）
可以创建定期执行的脚本：

```bash
#!/bin/bash
# auto-update-cdn.sh

cd /path/to/your/acl_script/scripts

# 运行测试
./cdn-speedtest.sh

# 检查是否生成了新配置
if [ -f "*/hosts_updated.txt" ]; then
    # 备份并更新
    cp ../mosdns/hosts.txt ../mosdns/hosts.txt.$(date +%Y%m%d)
    cp */hosts_updated.txt ../mosdns/hosts.txt
    echo "✅ CDN 配置已自动更新"
fi
```

### 添加到 crontab（可选）
```bash
# 编辑 crontab
crontab -e

# 添加定期任务（每周日凌晨 2 点执行）
0 2 * * 0 /path/to/auto-update-cdn.sh >> /var/log/cdn-update.log 2>&1
```

## ⚠️ 注意事项

### 网络环境要求
- 📶 **稳定网络**：确保测试期间网络连接稳定
- 🌐 **外网访问**：需要能够访问 GitHub 和各 CDN 节点
- 🚫 **避免代理**：测试时建议关闭 VPN 或代理

### 安全注意事项
- 💾 **数据备份**：测试前备份原有配置文件
- 🔒 **权限控制**：不要以 root 权限运行脚本
- 📝 **日志记录**：保留测试日志便于问题排查

### 性能影响
- ⏱️ **测试时间**：完整测试通常需要 3-10 分钟
- 💻 **系统资源**：测试期间会占用一定网络带宽和 CPU
- 📊 **并发限制**：避免同时运行多个测试实例

## 🆘 获取帮助

### 问题反馈
如遇到问题，请提供以下信息：
- 操作系统版本
- 网络环境信息
- 完整的错误信息
- 脚本执行日志

### 调试模式
启用详细日志输出：
```bash
# 调试模式运行
bash -x ./cdn-speedtest.sh > debug.log 2>&1
```

### 手动测试单个 IP
```bash
# 测试 Cloudflare IP
curl -o /dev/null -s -w "%{time_total}\n" --connect-timeout 5 "http://104.16.120.95/"

# 测试 CloudFront IP  
curl -o /dev/null -s -w "%{time_total}\n" --connect-timeout 5 "http://54.230.129.74/"
```

## 📋 版本信息

- **当前版本**：v1.0
- **支持的 CDN**：Cloudflare, AWS CloudFront
- **兼容系统**：Linux, macOS
- **最后更新**：2024-01-XX

---

> 💡 **提示**：首次使用建议先运行 `quick-cdn-test.sh` 验证当前配置，再执行完整优选测试。

> ⚠️ **重要**：此脚本仅在你的本地网络环境中测试，结果仅适用于当前网络环境。