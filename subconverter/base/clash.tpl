{% if global.clash.mixed_port > 0 %}
# HTTP(S) 和 SOCKS 代理混合端口
mixed-port: {{ default(global.clash.http_port, "50001") }}
{% else %}
# HTTP(S) 代理服务器端口
port: {{ default(global.clash.http_port, "7890") }}
# SOCKS5 代理端口
socks-port: {{ default(global.clash.socks_port, "7891") }}
{% endif %}

# Transparent proxy server port for Linux (TProxy TCP and TProxy UDP)
# tproxy-port: 7893

# 允许局域网连接
allow-lan: {{ default(global.clash.allow_lan, "true") }}

{% if global.clash.allow_lan %}
# 局域网配置
# 绑定 IP 地址，仅作用于 allow-lan 为 true, '*'表示所有地址
bind-address: {{ default(global.clash.bind_addr, "\"*\"") }}

{% if default(global.clash.lan_need_auth, "false") %}
authentication: # http,socks 入口的验证用户名，密码
  - "{{ default(global.clash.authentication, "admin:admin") }}"
{% endif %}

# 设置跳过验证的 IP 段
skip-auth-prefixes:
  - 127.0.0.1/8
  - ::1/128

# 允许连接的 IP 地址段，仅作用于 allow-lan 为 true, 默认值为 0.0.0.0/0 和::/0
lan-allowed-ips:
  - 0.0.0.0/0
  - ::/0

# 禁止连接的 IP 地址段，黑名单优先级高于白名单，默认值为空
lan-disallowed-ips: 
  - 192.168.0.254/32

# 局域网配置 end
{% endif %}

#  find-process-mode has 3 values:always, strict, off
#  - always, 开启，强制匹配所有进程
#  - strict, 默认，由 mihomo 判断是否开启
#  - off, 不匹配进程，推荐在路由器上使用此模式
find-process-mode: {{ default(global.clash.find_process_mode, "strict") }}

mode: {{ default(global.clash.mode, "Rule") }}

#自定义 geodata url
geox-url:
  geoip: {{ default(global.clash.geoip_url, "https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat") }}
  geosite: {{ default(global.clash.geoip_url, "https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat") }}
  mmdb: {{ default(global.clash.geoip_url, "https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb") }}

geo-auto-update: true # 是否自动更新 geodata
geo-update-interval: 24 # 更新间隔，单位：小时

# Matcher implementation used by GeoSite, available implementations:
# - succinct (default, same as rule-set)
# - mph (from V2Ray, also `hybrid` in Xray)
# geosite-matcher: succinct

log-level: {{ default(global.clash.log_level, "info") }}

# 开启 IPv6 总开关，关闭阻断所有 IPv6 链接和屏蔽 DNS 请求 AAAA 记录
ipv6: {{ default(global.clash.enable_ipv6, "false") }}

# RESTful API 监听地址
external-controller: {{ default(global.clash.external_controller_listen, ":9090") }}
# secret: "123456"

# RESTful API Unix socket 监听地址（ windows版本大于17063也可以使用，即大于等于1803/RS4版本即可使用 ）
# ！！！注意： 从Unix socket访问api接口不会验证secret， 如果开启请自行保证安全问题 ！！！
# 测试方法： curl -v --unix-socket "mihomo.sock" http://localhost/
external-controller-unix: mihomo.sock

# tcp-concurrent: true # TCP 并发连接所有 IP, 将使用最快握手的 TCP

# 在RESTful API端口上开启DOH服务器
# ！！！该URL不会验证secret， 如果开启请自行保证安全问题 ！！！
external-doh-server: /dns-query

# interface-name: en0 # 设置出口网卡

# 全局 TLS 指纹，优先低于 proxy 内的 client-fingerprint
# 可选： "chrome","firefox","safari","ios","random","none" options.
# Utls is currently support TLS transport in TCP/grpc/WS/HTTP for VLESS/Vmess and trojan.
global-client-fingerprint: chrome

#  TCP keep alive interval
keep-alive-interval: 15

# 类似于 /etc/hosts, 仅支持配置单个 IP
hosts:
# '*.mihomo.dev': 127.0.0.1
# '.dev': 127.0.0.1
# 'alpha.mihomo.dev': '::1'
# test.com: [1.1.1.1, 2.2.2.2]
# home.lan: lan # lan 为特别字段，将加入本地所有网卡的地址
# baidu.com: google.com # 只允许配置一个别名

profile: # 存储 select 选择记录
  store-selected: false

  # 持久化 fake-ip
  store-fake-ip: true

# Tun 配置
tun:
  enable: false
  stack: system # gvisor/mixed
  dns-hijack:
    - 0.0.0.0:53 # 需要劫持的 DNS
  # auto-detect-interface: true # 自动识别出口网卡
  # auto-route: true # 配置路由表
  # mtu: 9000 # 最大传输单元
  # gso: false # 启用通用分段卸载，仅支持 Linux
  # gso-max-size: 65536 # 通用分段卸载包的最大大小
  auto-redirect: false # 自动配置 iptables 以重定向 TCP 连接。仅支持 Linux。带有 auto-redirect 的 auto-route 现在可以在路由器上按预期工作，无需干预。
  # strict-route: true # 将所有连接路由到 tun 来防止泄漏，但你的设备将无法其他设备被访问
  route-address-set: # 将指定规则集中的目标 IP CIDR 规则添加到防火墙, 不匹配的流量将绕过路由, 仅支持 Linux，且需要 nftables，`auto-route` 和 `auto-redirect` 已启用。
    - ruleset-1
    - ruleset-2
  route-exclude-address-set: # 将指定规则集中的目标 IP CIDR 规则添加到防火墙, 匹配的流量将绕过路由, 仅支持 Linux，且需要 nftables，`auto-route` 和 `auto-redirect` 已启用。
    - ruleset-3
    - ruleset-4
  route-address: # 启用 auto-route 时使用自定义路由而不是默认路由
    - 0.0.0.0/1
    - 128.0.0.0/1
    - "::/1"
    - "8000::/1"
  # inet4-route-address: # 启用 auto-route 时使用自定义路由而不是默认路由（旧写法）
  #   - 0.0.0.0/1
  #   - 128.0.0.0/1
  # inet6-route-address: # 启用 auto-route 时使用自定义路由而不是默认路由（旧写法）
  #   - "::/1"
  #   - "8000::/1"
  # endpoint-independent-nat: false # 启用独立于端点的 NAT
  # include-interface: # 限制被路由的接口。默认不限制，与 `exclude-interface` 冲突
  #   - "lan0"
  # exclude-interface: # 排除路由的接口，与 `include-interface` 冲突
  #   - "lan1"
  # include-uid: # UID 规则仅在 Linux 下被支持，并且需要 auto-route
  # - 0
  # include-uid-range: # 限制被路由的的用户范围
  # - 1000:9999
  # exclude-uid: # 排除路由的的用户
  #- 1000
  # exclude-uid-range: # 排除路由的的用户范围
  # - 1000:9999

  # Android 用户和应用规则仅在 Android 下被支持
  # 并且需要 auto-route

  # include-android-user: # 限制被路由的 Android 用户
  # - 0
  # - 10
  # include-package: # 限制被路由的 Android 应用包名
  # - com.android.chrome
  # exclude-package: # 排除被路由的 Android 应用包名
  # - com.android.captiveportallogin

tunnels: 
  # one line config
  - tcp/udp,127.0.0.1:6553,114.114.114.114:53,direct
  - tcp,127.0.0.1:6666,rds.mysql.com:3306,direct
  # full yaml config
  - network: [tcp, udp]
    address: 127.0.0.1:7777
    target: target.com
    proxy: proxy

# DNS 配置
dns:
  cache-algorithm: arc
  enable: true # 关闭将使用系统 DNS
  prefer-h3: true # 是否开启 DoH 支持 HTTP/3，将并发尝试
  listen: 0.0.0.0:53 # 开启 DNS 服务器监听
  ipv6: false # false 将返回 AAAA 的空结果
  # ipv6-timeout: 300 # 单位：ms，内部双栈并发时，向上游查询 AAAA 时，等待 AAAA 的时间，默认 100ms
  # 用于解析 nameserver，fallback 以及其他 DNS 服务器配置的，DNS 服务域名
  # 只能使用纯 IP 地址，可使用加密 DNS
  default-nameserver:
    - 119.29.29.29
    - 223.5.5.5
    # append DNS server from system configuration. If not found, it would print an error log and skip.
    - system
  enhanced-mode: fake-ip # or redir-host

  fake-ip-range: 198.18.0.1/16 # fake-ip 池设置

  # 查询 hosts
  use-hosts: true 

  # 配置后面的nameserver、fallback和nameserver-policy向dns服务器的连接过程是否遵守遵守rules规则
  # 如果为false（默认值）则这三部分的dns服务器在未特别指定的情况下会直连
  # 如果为true，将会按照rules的规则匹配链接方式（走代理或直连），如果有特别指定则任然以指定值为准
  # 仅当proxy-server-nameserver非空时可以开启此选项, 强烈不建议和prefer-h3一起使用
  # 此外，这三者配置中的dns服务器如果出现域名会采用default-nameserver配置项解析，也请确保正确配置default-nameserver
  respect-rules: false

  # 配置不使用 fake-ip 的域名
  fake-ip-filter:
    - '+.urzz.me'
    - '*.lan'
    - localhost.ptlogin2.qq.com

  # DNS 主要域名配置
  # 支持 UDP，TCP，DoT，DoH，DoQ
  # 这部分为主要 DNS 配置，影响所有直连，确保使用对大陆解析精准的 DNS
  nameserver:
    - '8.8.8.8#RULES'
    - tls://223.5.5.5:853 # DNS over TLS
    - https://doh.pub/dns-query # DNS over HTTPS
    - https://dns.alidns.com/dns-query#h3=true # 强制 HTTP/3，与 perfer-h3 无关，强制开启 DoH 的 HTTP/3 支持，若不支持将无法使用
    - https://mozilla.cloudflare-dns.com/dns-query#DNS&h3=true # 指定策略组和使用 HTTP/3
    - dhcp://en0 # dns from dhcp


  # 配置查询域名使用的 DNS 服务器
  nameserver-policy:
    "geosite:cn,private":
      - https://doh.pub/dns-query
      - https://dns.alidns.com/dns-query
    "geosite:category-ads-all": rcode://success
    "www.baidu.com,+.google.cn": [223.5.5.5, https://dns.alidns.com/dns-query]
