#!/bin/bash

# 快速 CDN 测试脚本
# 适合快速测试和验证

echo "⚡ 快速 CDN 测试"
echo ""

# 测试单个 IP 的延迟和速度
test_ip() {
    local ip=$1
    local name=$2
    
    echo -n "测试 $name ($ip) ... "
    
    # 测试连通性和延迟
    if ping -c 3 -W 2 "$ip" >/dev/null 2>&1; then
        latency=$(ping -c 3 -W 2 "$ip" 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d' ' -f1)
        
        # 测试 HTTP 响应
        http_time=$(curl -o /dev/null -s -w "%{time_total}" --connect-timeout 3 --max-time 5 "http://$ip/" 2>/dev/null || echo "999")
        
        if (( $(echo "$http_time < 2" | bc -l 2>/dev/null || echo 0) )); then
            echo "延迟: ${latency}ms, HTTP: ${http_time}s ✅"
        else
            echo "延迟: ${latency}ms, HTTP超时 ⚠️"
        fi
    else
        echo "不可达 ❌"
    fi
}

echo "🔍 测试当前配置的 IP:"

# 从 hosts.txt 读取并测试
if [ -f "../mosdns/hosts.txt" ]; then
    while IFS= read -r line; do
        if [[ $line =~ ^domain:([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            domain="${BASH_REMATCH[1]}"
            ip="${BASH_REMATCH[2]}"
            test_ip "$ip" "$domain"
        fi
    done < "../mosdns/hosts.txt"
else
    echo "❌ 找不到 ../mosdns/hosts.txt 文件"
fi

echo ""
echo "💡 如需完整优选，请运行: ./cdn-speedtest.sh" 