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

mode: {{ default(global.clash.mode, "rule") }}

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
  '*.mihomo.dev': 127.0.0.1

profile: # 存储 select 选择记录
  store-selected: false

  # 持久化 fake-ip
  store-fake-ip: true

unified-delay: true

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
  enhanced-mode: fake-ip
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
    - '+.lan'
    - '+.local'
  # DNS 主要域名配置
  # 支持 UDP，TCP，DoT，DoH，DoQ
  # 这部分为主要 DNS 配置，影响所有直连，确保使用对大陆解析精准的 DNS
  nameserver:
    - https://8.8.8.8/dns-query
    - https://1.1.1.1/dns-query
  # 配置查询域名使用的 DNS 服务器
  nameserver-policy:
    "geosite:cn,private":
      - https://doh.pub/dns-query
      - https://dns.alidns.com/dns-query
