#!/bin/bash

# CDN 优选脚本 - 支持 Cloudflare 和 CloudFront
# 在你的本地网络环境中运行，获得真正适合你的优选 IP

set -e

echo "🚀 CDN 优选 IP 测试脚本"
echo "⚡ 支持 Cloudflare 和 AWS CloudFront"
echo "⚠️  请在你的本地网络环境中运行此脚本"
echo ""

# 使用固定的工作目录
WORK_DIR="$(pwd)/cdn_speedtest"
mkdir -p "$WORK_DIR"

echo "📁 工作目录: $WORK_DIR"

# 更新 .gitignore
update_gitignore() {
    GITIGNORE_FILE="$(pwd)/.gitignore"
    
    # 要添加到 gitignore 的内容
    GITIGNORE_CONTENT="
# CDN 测速脚本产生的文件
cdn_speedtest/
cdn_speedtest_*/
*.csv
*_results.txt
*_best.txt
*_updated.txt
CloudflareST*
cloudfront_ips.txt
"

    if [ ! -f "$GITIGNORE_FILE" ]; then
        echo "📝 创建 .gitignore 文件..."
        echo "# CDN 测速脚本产生的文件" > "$GITIGNORE_FILE"
        echo "cdn_speedtest/" >> "$GITIGNORE_FILE"
        echo "cdn_speedtest_*/" >> "$GITIGNORE_FILE"
        echo "*.csv" >> "$GITIGNORE_FILE"
        echo "*_results.txt" >> "$GITIGNORE_FILE"
        echo "*_best.txt" >> "$GITIGNORE_FILE"
        echo "*_updated.txt" >> "$GITIGNORE_FILE"
        echo "CloudflareST*" >> "$GITIGNORE_FILE"
        echo "cloudfront_ips.txt" >> "$GITIGNORE_FILE"
        echo "✅ .gitignore 文件已创建"
    else
        # 检查是否已经包含相关规则
        if ! grep -q "cdn_speedtest" "$GITIGNORE_FILE"; then
            echo "📝 更新 .gitignore 文件..."
            echo "" >> "$GITIGNORE_FILE"
            echo "# CDN 测速脚本产生的文件" >> "$GITIGNORE_FILE"
            echo "cdn_speedtest/" >> "$GITIGNORE_FILE"
            echo "cdn_speedtest_*/" >> "$GITIGNORE_FILE"
            echo "*.csv" >> "$GITIGNORE_FILE"
            echo "*_results.txt" >> "$GITIGNORE_FILE"
            echo "*_best.txt" >> "$GITIGNORE_FILE"
            echo "*_updated.txt" >> "$GITIGNORE_FILE"
            echo "CloudflareST*" >> "$GITIGNORE_FILE"
            echo "cloudfront_ips.txt" >> "$GITIGNORE_FILE"
            echo "✅ .gitignore 文件已更新"
        else
            echo "✅ .gitignore 文件已包含相关规则"
        fi
    fi
}

# 切换到工作目录
cd "$WORK_DIR"
echo ""

# 检查依赖
check_dependencies() {
    echo "🔍 检查依赖..."
    
    missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v wget &> /dev/null; then
        missing_deps+=("wget")
    fi
    
    # 添加bc检查
    if ! command -v bc &> /dev/null; then
        missing_deps+=("bc")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ 缺少依赖: ${missing_deps[*]}"
        echo "请安装这些依赖后再运行脚本"
        if [[ $(uname -a) =~ WSL ]]; then
            echo "WSL安装命令: sudo apt update && sudo apt install ${missing_deps[*]}"
        fi
        exit 1
    fi
    
    echo "✅ 依赖检查通过"
}

# 下载 CloudflareSpeedTest
download_cloudflare_speedtest() {
    echo ""
    echo "📥 检查 CloudflareSpeedTest..."
    
    # 检查是否已经存在可执行文件
    if [ -f "CloudflareST" ] && [ -x "CloudflareST" ]; then
        echo "✅ CloudflareST 已存在，跳过下载"
        return 0
    fi
    
    echo "🔍 检测到操作系统: $OSTYPE"
    
    DOWNLOAD_URL=""
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]] || [[ $(uname -s) == "Linux" ]]; then
        DOWNLOAD_URL="https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        DOWNLOAD_URL="https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_darwin_amd64.tar.gz"
    else
        echo "❌ 不支持的操作系统: $OSTYPE"
        echo "尝试手动下载CloudflareSpeedTest..."
        echo "下载地址: https://github.com/XIU2/CloudflareSpeedTest/releases"
        exit 1
    fi
    
    echo "📎 下载链接: $DOWNLOAD_URL"
    
    # 检查是否已经下载了压缩包
    if [ ! -f "CloudflareST.tar.gz" ]; then
        echo "📥 开始下载 CloudflareST.tar.gz..."
        echo "🔗 正在连接到 GitHub..."
        
        # 先检查网络连通性
        if ! curl -s --connect-timeout 10 -I "$DOWNLOAD_URL" > /dev/null; then
            echo "❌ 无法连接到下载地址，请检查网络连接"
            exit 1
        fi
        
        echo "✅ 网络连接正常，开始下载..."
        
        # 使用wget下载，显示进度条
        if command -v wget &> /dev/null; then
            echo "🚀 使用 wget 下载..."
            if wget --timeout=60 --tries=3 --progress=bar:force:noscroll \
                   --show-progress --no-check-certificate \
                   -O CloudflareST.tar.gz "$DOWNLOAD_URL" 2>&1; then
                echo "✅ wget 下载完成"
            else
                echo "❌ wget 下载失败，尝试使用 curl..."
                rm -f CloudflareST.tar.gz
                
                # 使用curl下载，显示进度条
                echo "🚀 使用 curl 下载..."
                if curl -L --connect-timeout 30 --max-time 300 \
                       --progress-bar --fail \
                       -o CloudflareST.tar.gz "$DOWNLOAD_URL"; then
                    echo "✅ curl 下载完成"
                else
                    echo "❌ 下载失败，请检查网络连接"
                    echo ""
                    echo "📋 手动下载步骤："
                    echo "1. 访问: https://github.com/XIU2/CloudflareSpeedTest/releases"
                    echo "2. 下载适合你系统的版本 (linux_amd64.tar.gz)"
                    echo "3. 将文件重命名为 CloudflareST.tar.gz 并放在当前目录"
                    echo "4. 重新运行脚本"
                    exit 1
                fi
            fi
        else
            # 只有curl可用
            echo "🚀 使用 curl 下载..."
            if curl -L --connect-timeout 30 --max-time 300 \
                   --progress-bar --fail \
                   -o CloudflareST.tar.gz "$DOWNLOAD_URL"; then
                echo "✅ curl 下载完成"
            else
                echo "❌ 下载失败，请检查网络连接"
                exit 1
            fi
        fi
        
        # 验证下载的文件大小
        if [ -f "CloudflareST.tar.gz" ]; then
            file_size=$(stat -f%z "CloudflareST.tar.gz" 2>/dev/null || stat -c%s "CloudflareST.tar.gz" 2>/dev/null || echo "0")
            if [ "$file_size" -lt 1000000 ]; then  # 小于1MB可能是错误页面
                echo "⚠️  下载的文件大小异常: ${file_size} bytes"
                echo "文件可能下载不完整，请检查网络或手动下载"
                ls -la CloudflareST.tar.gz
                exit 1
            else
                echo "✅ 文件大小正常: $(( file_size / 1024 / 1024 )) MB"
            fi
        fi
        
    else
        echo "✅ CloudflareST.tar.gz 已存在，跳过下载"
        # 检查现有文件大小
        if [ -f "CloudflareST.tar.gz" ]; then
            file_size=$(stat -f%z "CloudflareST.tar.gz" 2>/dev/null || stat -c%s "CloudflareST.tar.gz" 2>/dev/null || echo "0")
            echo "📊 现有文件大小: $(( file_size / 1024 / 1024 )) MB"
        fi
    fi
    
    # 检查下载的文件
    if [ ! -f CloudflareST.tar.gz ]; then
        echo "❌ 下载的文件不存在"
        exit 1
    fi
    
    # 解压文件
    echo "📦 解压 CloudflareST.tar.gz..."
    if ! tar -xzf CloudflareST.tar.gz; then
        echo "❌ 解压失败，文件可能损坏"
        echo "🗑️  删除损坏的文件..."
        rm -f CloudflareST.tar.gz
        echo "请重新运行脚本重新下载"
        exit 1
    fi
    
    # 检查可执行文件
    if [ ! -f CloudflareST ]; then
        echo "❌ CloudflareST可执行文件不存在"
        echo "📁 当前目录内容:"
        ls -la
        echo ""
        echo "🔍 尝试查找可执行文件..."
        find . -name "*CloudflareST*" -type f
        exit 1
    fi
    
    chmod +x CloudflareST
    
    # 验证可执行文件
    if ./CloudflareST -h > /dev/null 2>&1; then
        echo "✅ CloudflareSpeedTest 准备完成并可正常运行"
    else
        echo "⚠️  CloudflareST 下载完成，但可能无法正常运行"
        echo "请检查文件是否完整或尝试重新下载"
    fi
}

# 创建 CloudFront IP 列表
create_cloudfront_ips() {
    echo ""
    echo "📝 检查 CloudFront IP 列表..."
    
    # 如果文件已存在，检查是否需要更新
    if [ -f "cloudfront_ips.txt" ]; then
        echo "✅ cloudfront_ips.txt 已存在，跳过创建"
        return 0
    fi
    
    echo "📝 创建 CloudFront IP 列表..."
    
    # CloudFront IP 段（从 AWS 官方获取的主要 IP 段）
    cat > cloudfront_ips.txt << 'EOF'
# AWS CloudFront IP 段
# 这些是经过筛选的相对较优的 CloudFront IP 段
# 54.230.x.x 段
54.230.0.0/24
54.230.1.0/24
54.230.2.0/24
54.230.3.0/24
54.230.4.0/24
54.230.5.0/24
54.230.6.0/24
54.230.7.0/24
54.230.8.0/24
54.230.9.0/24
54.230.10.0/24
54.230.11.0/24
54.230.12.0/24
54.230.128.0/24
54.230.129.0/24
54.230.130.0/24
54.230.131.0/24
54.230.132.0/24
54.230.200.0/24
54.230.201.0/24
54.230.202.0/24
54.230.203.0/24
54.230.204.0/24

# 13.32.x.x 段
13.32.0.0/24
13.32.1.0/24
13.32.2.0/24
13.32.3.0/24
13.32.4.0/24
13.32.5.0/24

# 13.35.x.x 段
13.35.0.0/24
13.35.1.0/24
13.35.2.0/24

# 99.84.x.x 段
99.84.0.0/24
99.84.1.0/24
99.84.2.0/24
EOF

    echo "✅ CloudFront IP 列表创建完成"
}

# 测速 Cloudflare
test_cloudflare() {
    echo ""
    echo "⚡ 开始测速 Cloudflare..."
    echo "📊 参数: 延迟上限200ms, 速度下限2MB/s, 测试数量5个"
    
    # 使用适合中国大陆的参数
    ./CloudflareST -tl 200 -sl 2.0 -dn 5 -o cf_result.csv
    
    if [ -f cf_result.csv ]; then
        echo ""
        echo "📋 Cloudflare 测速结果:"
        cat cf_result.csv
        echo ""
        
        # 提取最佳 IP
        CF_BEST_IPS=($(tail -n +2 cf_result.csv | head -5 | cut -d',' -f1))
        echo "✅ 获得 ${#CF_BEST_IPS[@]} 个 Cloudflare 优选 IP"
    else
        echo "❌ Cloudflare 测速失败"
        CF_BEST_IPS=("104.16.120.95")  # 备用 IP
    fi
}

# 测速 CloudFront（使用简化的方法）
test_cloudfront() {
    echo ""
    echo "⚡ 开始测速 CloudFront..."
    echo "📊 使用 curl 测试延迟和可达性"
    
    # 从 CloudFront IP 列表中随机选择一些 IP 进行测试
    CF_FRONT_TEST_IPS=(
        "54.230.0.1" "54.230.1.1" "54.230.2.1" "54.230.3.1" "54.230.4.1"
        "54.230.128.1" "54.230.129.1" "54.230.130.1" "54.230.200.1"
        "13.32.0.1" "13.32.1.1" "13.32.2.1" "13.35.0.1" "99.84.0.1"
    )
    
    echo "🔍 测试 ${#CF_FRONT_TEST_IPS[@]} 个 CloudFront IP..."
    
    > cloudfront_results.txt
    
    for ip in "${CF_FRONT_TEST_IPS[@]}"; do
        echo -n "测试 $ip ... "
        
        # 测试延迟和可达性
        start_time=$(date +%s%3N)
        response=$(curl -s -o /dev/null -w "%{http_code},%{time_total}" --connect-timeout 3 --max-time 5 "http://$ip/" 2>/dev/null || echo "000,99.999")
        end_time=$(date +%s%3N)
        
        http_code=$(echo $response | cut -d',' -f1)
        time_total=$(echo $response | cut -d',' -f2)
        latency=$(echo "scale=2; $time_total * 1000" | bc 2>/dev/null || echo "999.99")
        
        if [ "$http_code" != "000" ] && (( $(echo "$latency < 500" | bc -l) )); then
            echo "$ip,$latency" >> cloudfront_results.txt
            echo "延迟: ${latency}ms ✅"
        else
            echo "超时或不可达 ❌"
        fi
    done
    
    # 按延迟排序并选择前5个
    if [ -f cloudfront_results.txt ] && [ -s cloudfront_results.txt ]; then
        echo ""
        echo "📋 CloudFront 测速结果:"
        sort -t',' -k2 -n cloudfront_results.txt | head -5 > cloudfront_best.txt
        cat cloudfront_best.txt
        
        CF_FRONT_BEST_IPS=($(cut -d',' -f1 cloudfront_best.txt))
        echo ""
        echo "✅ 获得 ${#CF_FRONT_BEST_IPS[@]} 个 CloudFront 优选 IP"
    else
        echo "❌ CloudFront 测速失败，使用默认 IP"
        CF_FRONT_BEST_IPS=("54.230.129.74" "54.230.0.118")
    fi
}

# 更新配置文件
update_config_files() {
    echo ""
    echo "📝 生成配置文件..."
    
    # 读取原始的 hosts.txt 来识别域名
    ORIGINAL_HOSTS="../mosdns/hosts.txt"
    if [ ! -f "$ORIGINAL_HOSTS" ]; then
        echo "❌ 找不到原始 hosts.txt 文件: $ORIGINAL_HOSTS"
        return 1
    fi
    
    # 识别 Cloudflare 和 CloudFront 域名
    CF_DOMAINS=()
    CF_FRONT_DOMAINS=()
    
    while IFS= read -r line; do
        # 跳过注释和空行
        if [[ $line =~ ^[[:space:]]*# ]] || [[ $line =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        
        if [[ $line =~ ^domain:([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            domain="${BASH_REMATCH[1]}"
            ip="${BASH_REMATCH[2]}"
            
            # 判断是 Cloudflare 还是 CloudFront
            if [[ $ip =~ ^104\.(1[6-9]|2[0-9]|3[01])\.|^172\.6[7-9]\.|^172\.7[01]\.|^162\.159\. ]]; then
                CF_DOMAINS+=("$domain")
                echo "🔵 Cloudflare 域名: $domain (原IP: $ip)"
            elif [[ $ip =~ ^54\.230\.|^13\.32\.|^13\.35\.|^99\.84\.|^52\.84\.|^204\.246\.|^54\.182\.|^54\.192\. ]]; then
                CF_FRONT_DOMAINS+=("$domain")
                echo "🟠 CloudFront 域名: $domain (原IP: $ip)"
            else
                echo "⚪ 其他域名: $domain (保持原IP: $ip)"
            fi
        fi
    done < "$ORIGINAL_HOSTS"
    
    echo ""
    echo "📊 域名统计:"
    echo "   Cloudflare 域名: ${#CF_DOMAINS[@]} 个"
    echo "   CloudFront 域名: ${#CF_FRONT_DOMAINS[@]} 个"
    
    # 生成 Cloudflare 域名配置
    if [ ${#CF_DOMAINS[@]} -gt 0 ] && [ ${#CF_BEST_IPS[@]} -gt 0 ]; then
        echo ""
        echo "📄 生成 cf_domain.txt..."
        {
            echo "# Cloudflare 域名列表 - 本地网络优选"
            echo "# 更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "# 测试环境: 本地网络"
            echo "# 负载均衡策略: 不同域名使用不同优选IP"
            echo "# 格式：domain:域名 IP地址"
            echo ""
            
            for i in "${!CF_DOMAINS[@]}"; do
                domain="${CF_DOMAINS[$i]}"
                ip="${CF_BEST_IPS[$((i % ${#CF_BEST_IPS[@]}))]}"
                printf "domain:%-20s %s\n" "$domain" "$ip"
            done
        } > cf_domain.txt
        
        echo "✅ cf_domain.txt 生成完成"
    fi
    
    # 生成 CloudFront 域名配置
    if [ ${#CF_FRONT_DOMAINS[@]} -gt 0 ] && [ ${#CF_FRONT_BEST_IPS[@]} -gt 0 ]; then
        echo ""
        echo "📄 生成 cloudfront_domain.txt..."
        {
            echo "# CloudFront 域名列表 - 本地网络优选"
            echo "# 更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "# 测试环境: 本地网络"
            echo "# 负载均衡策略: 不同域名使用不同优选IP"
            echo "# 格式：domain:域名 IP地址"
            echo ""
            
            for i in "${!CF_FRONT_DOMAINS[@]}"; do
                domain="${CF_FRONT_DOMAINS[$i]}"
                ip="${CF_FRONT_BEST_IPS[$((i % ${#CF_FRONT_BEST_IPS[@]}))]}"
                printf "domain:%-20s %s\n" "$domain" "$ip"
            done
        } > cloudfront_domain.txt
        
        echo "✅ cloudfront_domain.txt 生成完成"
    fi
    
    # 生成更新后的 hosts.txt
    echo ""
    echo "📄 生成更新后的 hosts.txt..."
    {
        echo "# 更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# 本地网络环境优选结果"
        echo "# 负载均衡策略: 相同CDN的不同域名使用不同优选IP以分散负载"
        echo ""
        
        while IFS= read -r line; do
            # 保持注释和空行
            if [[ $line =~ ^[[:space:]]*# ]] || [[ $line =~ ^[[:space:]]*$ ]]; then
                echo "$line"
                continue
            fi
            
            if [[ $line =~ ^domain:([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
                domain="${BASH_REMATCH[1]}"
                old_ip="${BASH_REMATCH[2]}"
                
                # 查找是否有新的优选 IP
                new_ip="$old_ip"  # 默认保持原 IP
                
                # 检查是否是 Cloudflare 域名
                for i in "${!CF_DOMAINS[@]}"; do
                    if [ "$domain" == "${CF_DOMAINS[$i]}" ] && [ ${#CF_BEST_IPS[@]} -gt 0 ]; then
                        new_ip="${CF_BEST_IPS[$((i % ${#CF_BEST_IPS[@]}))]}"
                        break
                    fi
                done
                
                # 检查是否是 CloudFront 域名
                for i in "${!CF_FRONT_DOMAINS[@]}"; do
                    if [ "$domain" == "${CF_FRONT_DOMAINS[$i]}" ] && [ ${#CF_FRONT_BEST_IPS[@]} -gt 0 ]; then
                        new_ip="${CF_FRONT_BEST_IPS[$((i % ${#CF_FRONT_BEST_IPS[@]}))]}"
                        break
                    fi
                done
                
                printf "domain:%-20s %s" "$domain" "$new_ip"
                if [ "$new_ip" != "$old_ip" ]; then
                    echo "  # 已优选: $old_ip -> $new_ip"
                else
                    echo ""
                fi
            elif [[ $line =~ ^regexp: ]]; then
                # 保持正则表达式规则不变
                echo "$line"
            else
                # 保持其他格式的行不变
                echo "$line"
            fi
        done < "$ORIGINAL_HOSTS"
    } > hosts_updated.txt
    
    echo "✅ hosts_updated.txt 生成完成"
    
    # 验证所有域名都被包含
    echo ""
    echo "🔍 验证生成的文件..."
    original_domains=$(grep -E '^domain:' "$ORIGINAL_HOSTS" | wc -l)
    updated_domains=$(grep -E '^domain:' hosts_updated.txt | wc -l)
    echo "   原始文件域名数量: $original_domains"
    echo "   更新文件域名数量: $updated_domains"
    
    if [ "$original_domains" -eq "$updated_domains" ]; then
        echo "✅ 所有域名都已正确包含"
    else
        echo "⚠️  域名数量不匹配，请检查"
        echo "原始文件中的域名:"
        grep -E '^domain:' "$ORIGINAL_HOSTS" | cut -d: -f2 | cut -d' ' -f1
        echo "更新文件中的域名:"
        grep -E '^domain:' hosts_updated.txt | cut -d: -f2 | cut -d' ' -f1
    fi
}

# 显示结果和使用说明
show_results() {
    echo ""
    echo "🎉 CDN 优选完成！"
    echo ""
    echo "📊 测试结果总结:"
    echo "   Cloudflare 优选 IP: ${#CF_BEST_IPS[@]} 个"
    echo "   CloudFront 优选 IP: ${#CF_FRONT_BEST_IPS[@]} 个"
    echo ""
    echo "📁 生成的文件:"
    ls -la *.txt *.csv 2>/dev/null | grep -E '\.(txt|csv)$' || echo "   (无文件生成)"
    echo ""
    echo "💡 使用方法:"
    echo "1. 查看 hosts_updated.txt 文件，这是更新后的完整配置"
    echo "2. 将 hosts_updated.txt 复制到你的 mosdns/hosts.txt"
    echo "3. 或者分别使用 cf_domain.txt 和 cloudfront_domain.txt"
    echo ""
    echo "🔄 复制命令:"
    echo "   cp $WORK_DIR/hosts_updated.txt ../mosdns/hosts.txt"
    if [ -f cf_domain.txt ]; then
        echo "   cp $WORK_DIR/cf_domain.txt ../mosdns/"
    fi
    if [ -f cloudfront_domain.txt ]; then
        echo "   cp $WORK_DIR/cloudfront_domain.txt ../mosdns/"
    fi
    echo ""
    echo "⚠️  建议: 测试新 IP 是否正常工作后再正式使用"
}

# 主函数
main() {
    update_gitignore
    check_dependencies
    download_cloudflare_speedtest
    create_cloudfront_ips
    test_cloudflare
    test_cloudfront
    update_config_files
    show_results
}

# 运行主函数
main "$@" 