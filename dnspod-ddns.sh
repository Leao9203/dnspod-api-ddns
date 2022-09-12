#!/usr/bin/env bash

# DNSPod Token 的 ID
ID=

# DNSPod Token ID 所对应的 Token
Token=

# DDNS 的主域名，例如 ascn.site
domain=

# DDNS 的域名记录，例如 blog
record=

# DDNS 的类型，允许的值为 A 或者 AAAA
record_type=A

# 检测出口 IP 的 API，可选输入，例如 ip.sb，或者我所搭建的 ip.leao9203.xyz，建议优先自己搭建一个
ip_api=ip.leao9203.xyz

# 是否忽略 IP 变化，强制更新。如果启用，请设置为 true
force=false

# 获取输入参数
while getopts i:k:d:r:t:a:f: opts; do
  case ${opts} in
    i) ID=${OPTARG} ;;
    k) Token=${OPTARG} ;;
    d) domain=${OPTARG} ;;
    r) record=${OPTARG} ;;
    t) record_type=${OPTARG} ;;
    a) ip_api=${OPTARG} ;;
    f) force=${OPTARG} ;;
    *) echo "无效参数，请重新输入" && exit 1 ;; 
  esac
done

if [ "${ID}" = "" ]; then
    echo "请输入 DNSPod Token 的 ID"
    echo "可从这里获取 https://console.dnspod.cn/account/token/token"
   exit 1
fi

if [ "${Token}" = "" ]; then
    echo "请输入 DNSPod Token ID 所对应的 Token 值"
    echo "可从这里获取 https://console.dnspod.cn/account/token/token"
   exit 1
fi

if [ "${domain}" = "" ]; then
    echo "请输入域名"
    echo "例如 ascn.site"
   exit 1
fi

if [ "${record}" = "" ]; then
    echo "请输入记录值"
    echo "例如 blog.ascn.site"
    echo "则输入 blog"
   exit 1
fi

if [ "${record_type}" = "" ]; then
    echo "请输入记录类型 A | AAAA"
   exit 1
fi

if [ "${ip_api}" = "" ]; then
    echo "请输入获取 IP 的 API"
    echo "例如 ip.leao9203.xyz"
   exit 1
fi

if [ "${force}" = "" ]; then
     echo "请确认是否强制更新 true | false"
    exit 1
fi

# 本机 IP
ip=

# 获取 IP
if [ "${record_type}" = "AAAA" ]; then
    ip=$(curl -s -6 "${ip_api}" | grep -v %)
elif [ "${record_type}" = "A" ]; then
    ip=$(curl -s -4 "${ip_api}" | grep -v %)
fi

# 运行目录，以及 IP 文件
config_path=$HOME/.config/dnspod-ddns
ip_file=${config_path}/${record}.${domain}.ip.txt

# 判断是否存在配置目录
if [ ! -d "${config_path}" ]; then
     mkdir -p "${config_path}"
fi

# 判断是否存在 IP 文件、IP 是否更改
if [ ! -f "${ip_file}" ]; then
     echo "${ip}" >> "${ip_file}"
elif [ "$(cat "${ip_file}")" = "${ip}" ] && [ ! "${force}" = true ]; then
     echo "IP 未改变，将不进行更新"
    exit 0
fi

# 组合出 DNSPod 的新鉴权 API
login_token=${ID},${Token}

# 获取 DNSPod 的记录 ID
record_id=$(curl -s -X POST https://dnsapi.cn/Record.List -d "login_token=${login_token}" -d "domain=${domain}" -d "format=xml" | grep -B 6 "${record}" | grep id | sed -e 's/<[^>]*>//g')

# 更新 IP
curl -s -X POST https://dnsapi.cn/Record.Modify -d "login_token=${login_token}&domain=${domain}&format=xml&record_id=${record_id}&sub_domain=${record}&record_type=${record_type}&record_line_id=0&value=${ip}"