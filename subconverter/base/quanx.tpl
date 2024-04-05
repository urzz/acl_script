;general 模块内为一些通用的设置参数项
[general]
server_check_url= http://www.qualcomm.cn/generate_204
server_check_timeout=2000
resource_parser_url= https://fastly.jsdelivr.net/gh/KOP-XIAO/QuantumultX@master/Scripts/resource-parser.js
geo_location_checker=http://ip-api.com/json/?lang=zh-CN, https://raw.githubusercontent.com/KOP-XIAO/QuantumultX/master/Scripts/IP_API.js
running_mode_trigger=filter, filter, xthome_5G:all_direct, xthome_2.4G:all_direct
dns_exclusion_list= *.cmpassport.com, *.jegotrip.com.cn, *.icitymobile.mobi, id6.me, *.pingan.com.cn, *.cmbchina.com
fallback_udp_policy=direct

[dns]
server=119.29.29.29:53
server=223.5.5.5
server=119.28.28.28
server=114.114.114.114
server=202.141.176.93 
server=202.141.178.13
server=117.50.10.10

[task_local]

[policy]
static=♻️ 自动选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Auto.png
static=🚀 节点选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Proxy.png
static=🚀 手动选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Static.png
static=📲 电报消息, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Telegram.png
static=💬 OpenAi, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Bot.png
static=🌍 国外媒体, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/GlobalMedia.png
static=Ⓜ️ 微软云盘, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/OneDrive.png
static=Ⓜ️ 微软Bing, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Microsoft.png
static=Ⓜ️ 微软服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Microsoft.png
static=🍎 苹果服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Apple.png
static=🎮 游戏平台, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Game.png
static=📹 油管视频, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/YouTube.png
static=🎥 奈飞视频, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Netflix.png
static=🎯 全球直连, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Direct.png
static=🛑 广告拦截, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Advertising.png
static=🐟 漏网之鱼, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Final.png
static=🏡 HomeLab, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Drill.png
static=🇺🇲 美国节点, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/US.png
static=🤖 AI节点, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Bot.png

[server_remote]

#规则分流远程订阅
[filter_remote]

#rewrite 复写远程订阅
[rewrite_remote]

# 本地服务器部分
[server_local]

#本地分流规则(对于完全相同的某条规则，本地的将优先生效)
[filter_local]

#本地复写规则
[rewrite_local]

#以下为证书&主机名部分
[mitm]

