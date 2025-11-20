#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'
logFile=/tmp/upload/aliyddnsv6_log.txt
logMax=1000
nowTime=$(echo_date)
eval $(dbus export aliyddnsv6_)

[ -z "$aliyddnsv6_dns" ] && aliyddnsv6_dns="223.5.5.5"
[ -z "$aliyddnsv6_ttl" ] && aliyddnsv6_ttl="600"

clean_log() { # 清除历史日志
	[ $(wc -l "$logFile" | awk '{print $1}') -le "$logMax" ] && return
	local logdata=$(tail -n 500 "$logFile")
	echo "$logdata" > $logFile 2> /dev/null
	unset logdata
	echo_date "[update.sh]：日志数量超限，清除历史记录"
}

resolve_ip() { # 运营商解析记录IP nelookup命令  参数 [$1]RR [$2]Domain
	case "$1" in
		\*)
			local domain=www.$2;
		;;
		\@)
			local domain=$2;
		;;
		*)
			local domain=$1.$2;
		;;
	esac

	local dns=${aliyddnsv6_dns}
	local response=$(nslookup "$domain" "$dns" 2>/dev/null)
	local length=$(echo "$response" | grep "Name:")

	if [ ${#length} -gt 0 ]; then
		local address=$(echo "$response" | grep 'Address 1: ' | tail -n1)
		local ipv4=$(echo "$address" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
		local ipv6=$(echo "$address" | grep -Eo '\S*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\S*')

		if [ -n "$ipv4" ]; then
			echo "${ipv4}"
		elif [ -n "$ipv6" ]; then
			echo "${ipv6}"
		else
			echo ""
		fi
	else
		echo ""
	fi
}

get_iptype() { # 取IP地址类型  参数 [$1]IP地址
	local formatv4=$(echo "$1" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
	local formatv6=$(echo "$1" | grep -Eo '^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*')
	if [ -n "$formatv4" ] && [ -z "$formatv6" ] && [ "$formatv4" = "$1" ]; then
		echo "A"
		return 0
	elif [ -n "$formatv6" ] && [ -z "$formatv4" ] && [ "$formatv6" = "$1" ]; then
		echo "AAAA"
		return 0
	else
		echo ""
		return 1
	fi
}

get_ipaddr() { # 获取IP地址  参数 [$1]获取途径类型 其中[0]ppp0 [1]wan0 [2]v6.ip.zxinc.org [3]v6.meibu.com [9]自定义脚本(参数 [$2]Base64编码类型脚本命令)
	local ip=""
	local script=""
	case "$1" in
		0)
			local ipv6s=`ifconfig ppp0 | awk '/Global/{print $3}' | awk -F/ '{print $1}'` || die "$ip"
			for ip in $ipv6s
			do
				#ipv6 = $ipv6
				break
			done
		;;
		1)
			ip=$(nvram get wan0_realip_ip)
		;;
		2)
			ip=$(curl -s v6.ip.zxinc.org/getip 2>&1 | grep -Eo '^\S*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\S*' | grep -v "Terminated")
		;;
		3)
			ip=$(curl -s v6.meibu.com/ips.asp 2>&1 | grep -Eo '^\S*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\S*' | grep -v "Terminated")
		;;
		9)
			[ -n "$2" ] && script=`echo $2 | openssl enc -base64 -d`
			[ -n "$script" ] && ip=$(eval ${script} 2>&1)
		;;
		*)
			ip=""
		;;
	esac
	echo ${ip}
}

url_encode() { # URL编码  参数 [$1]待编码的字符串
	encode() {
		local out=""
		while read -n1 c
		do
			case $c in
				[a-zA-Z0-9._-])
				out="$out$c"
			;;
			*)
				out="$out`printf '%%%02X' "'$c"`"
			;;
			esac
		done
		echo -n $out
	}
	echo -n "$1" | encode
}

# 阿里云DDNS解析API开发文档网址https://help.aliyun.com/document_detail/29771.html?spm=a2c4g.29771.0.0.7f2e2452CeWXDW
send_request() { # 发送请求数据   参数 [$1]Action操作类型 [$2]请求所有参数
	local ak=$aliyddnsv6_ak  # 阿里云AccessKeyID
	local sk=$aliyddnsv6_sk  # 阿里云AccessKeySecret
	local args="AccessKeyId=$ak&Action=$1&Format=json&$2&Version=2015-01-09"
	local hash=$(echo -n "GET&%2F&$(url_encode "$args")" | openssl dgst -sha1 -hmac "$sk&" -binary | openssl base64)
	curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(url_encode "$hash")"
}

query_record() { # 获取云解析记录信息  参数 [$1]RR [$2]Domain
	local timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"` # 声明时间戳变量
	local random=$(date +%s)$(cat /proc/sys/kernel/random/uuid|sed 's/[^0-9]//g'|cut -c 1-3) # 取13位随机数
	send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$random&SignatureVersion=1.0&SubDomain=$1.$2&Timestamp=$timestamp&Type=" # Type类型为空时表示所有记录类型
}

get_recordid() { # 从云解析记录结果筛选Id  参数 [$1]查询结果Response
	echo $1 | grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}

get_recordip() { # 从云解析记录结果筛选IP  参数 [$1]查询结果Response
	# IPv6正则表达式
	# echo $1 | grep -Eo '"Value":"\S*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\S*"' | cut -d'"' -f4
	# 兼容IPv4与IPv6模式
	echo $1 | sed 's/,/\n/g' | grep "Value" | sed -n '1 s/:/\n/p' | sed '1d' | sed 's/"//g' | sed 's/}//g'
}

get_recordcount() { # 从云解析记录结果筛选TotalCount  参数 [$1]查询结果Response
	echo $1 | grep -Eo '"TotalCount":[0-9]+,' | cut -d':' -f2 | tr -d ','
}

get_recordmsg() { # 从云解析记录结果筛选Msg  参数 [$1]查询结果Response
	echo $1 | grep -Eo '"Message":"(.*[a-zA-Z][\.])"' | cut -d':' -f2 | tr -d '"'
}

update_record() { # 更新云解析记录   参数 [$1]RecordId [$2]RR [$3]IP [$4]Type
	local ttl=${aliyddnsv6_ttl:-600} # 取默认值
	local timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"` # 声明时间戳变量
	local random=$(date +%s)$(cat /proc/sys/kernel/random/uuid|sed 's/[^0-9]//g'|cut -c 1-3) # 取13位随机数
	send_request "UpdateDomainRecord" "RR=$2&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$random&SignatureVersion=1.0&TTL=$ttl&Timestamp=$timestamp&Type=$4&Value=$(url_encode $3)"
}
	
add_record() { # 新增云解析记录   参数 [$1]RR [$2]Domain [$3]IP [$4]Type
	local ttl=${aliyddnsv6_ttl:-600}
	local timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"` # 声明时间戳变量
	local random=$(date +%s)$(cat /proc/sys/kernel/random/uuid|sed 's/[^0-9]//g'|cut -c 1-3) # 取13位随机数
	send_request "AddDomainRecord&DomainName=$2" "RR=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$random&SignatureVersion=1.0&TTL=$ttl&Timestamp=$timestamp&Type=$4&Value=$(url_encode $3)"
}

del_record(){ # 删除云解析记录   参数 [$1]RecordId
	local timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"` # 声明时间戳变量
	local random=$(date +%s)$(cat /proc/sys/kernel/random/uuid|sed 's/[^0-9]//g'|cut -c 1-3) # 取13位随机数
	send_request "DeleteDomainRecord" "RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$random&SignatureVersion=1.0&Timestamp=$timestamp"
}

del_recordall(){ # 删除云解析全部记录   参数 [$1]RR [$2]Domain
	local timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"` # 声明时间戳变量
	local random=$(date +%s)$(cat /proc/sys/kernel/random/uuid|sed 's/[^0-9]//g'|cut -c 1-3) # 取13位随机数
	send_request "DeleteSubDomainRecords&DomainName=$2" "PageSize=500&RR=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$random&SignatureVersion=1.0&Timestamp=$timestamp&Type=" # Type类型为空时表示所有记录类型
}

get_json(){ # 取JSON中的字段    参数 [$1]Response [$2]字段名称(忽略大小写)
	echo "$1" | sed 's/,/\n/g' | grep -i "$2" | sed -n '1 s/:/\n/p' | sed '1d' | sed 's/"//g' | sed 's/}//g'
}

start_update() { # 开始更新
	local wanip=$(get_ipaddr $aliyddnsv6_comd)
	if [ -z "$wanip" ]; then
		dbus set aliyddnsv6_last_act="无法获取系统公网IP地址"
		echo_date "[update.sh]：无法获取系统公网IP地址"
		exit 0
	else
		dbus set aliyddnsv6_last_act="正常运行中"
		dbus set aliyddnsv6_ipv6=$(get_ipaddr "0")
		dbus set aliyddnsv6_ipv4=$(get_ipaddr "1")
	fi

	# 取域名数组
	local value=${aliyddnsv6_domain}
	local new_domain=""
	local i=0
	local array=$(echo $value | awk -F';' '{print NF-1}')

	while [ $i -le $array ]
	do
		local rr=${value%%,*} # 取第1个逗号前
		# 添加"*"和"@"类型子域名支持
		case "${rr}" in
			\*)
				local enrr="www";
			;;
			\@)
				local enrr="%40";
			;;
			*)
				local enrr=${rr};
			;;
		esac

		value=${value#*,} # 截断逗号前字符
		local domain=${value%%,*} # 取第2个逗号前
		value=${value#*,} # 再截断逗号前字符
		local option=${value%%,*} # 取第3个逗号前
		value=${value#*,} # 再截断逗号前字符
		local id=${value%%;*} # 取分号前
		value=${value#*;} # 再截断逗号前字符

		if [ "$option" = "0" ];then
			local ip=${wanip}
		else
			local script=`eval echo '$'aliyddnsv6_script$option`
			local ip=$(get_ipaddr "9" $script)
		fi

		local format=$(get_iptype "$ip") # 获取IP地址类型
		local current_ip=$(resolve_ip "$rr" "$domain") # 获取运营商域名解析记录IP

		# 与运营商域名解析记录比较IP地址
		if [ -z "$format" ]; then
			echo_date "[update.sh]：无法获取${rr}.${domain}的公网IP地址"
		elif [ -n "$current_ip" ] && [ "$ip" = "$current_ip" ]; then
			echo_date "[update.sh]：${rr}.${domain}运营商解析无变化"
		else
			local response=$(query_record $enrr $domain) # 获取阿里云域名解析记录
			local record_ip=$(get_recordip $response) # 获取阿里云域名解析记录IP
			local record_id=$(get_recordid $response) # 获取阿里云域名解析记录ID
			local record_num=$(get_recordcount $response) # 获取阿里云域名解析记录数量
			local record_msg=$(get_recordmsg "$response") # 获取阿里云域名解析错误信息

			# 判断阿里云解析记录数量是否存在多条
			if [ $record_num -gt 1 ]; then
				echo_date "[update.sh]：${rr}.${domain}云解析记录共$record_num条, 重建云解析记录"
				$(del_recordall $enrr $domain) >/dev/null 2>&1
				record_num=0
				record_id=""
				record_ip=""
				record_msg=""
			fi

			# 与阿里云解析记录比较IPv6地址
			if [ "$ip" = "$record_ip" ]; then
				[ "$id" != "$record_id" ] && id="${record_id}"
				echo_date "[update.sh]：${rr}.${domain}阿里云解析无变化"
			elif [ -z "$record_id" ];then
				if [ -n "$id" ];then
					del_record $id >/dev/null 2>&1
					[ -n "$record_msg" ] && echo_date "[update.sh]：${rr}.${domain}查询云解析记录失败, 错误提示 $record_msg"
				fi
				response=$(add_record "$enrr" "$domain" "$ip" "$format")
				record_id=$(get_recordid "$response")
				record_msg=$(get_recordmsg "$response")
				if [ -n "$record_id" ];then
					echo_date "[update.sh]：${rr}.${domain}添加云解析记录成功"
					# 检测用户是否更改了二级域名导致RecordId变化
					if [ -n "$id" ] && [ "$record_id" != "$id" ];then
						del_record $id >/dev/null 2>&1
						id="$record_id"
					fi
				else
					[ -n "$id" ] && del_record $id >/dev/null 2>&1
					id=""
					echo_date "[update.sh]：${rr}.${domain}添加云解析记录失败, 错误提示 $record_msg"
				fi
			else
				response=$(update_record "$record_id" "$enrr" "$ip" "$format")
				record_id=$(get_recordid "$response")
				record_msg=$(get_recordmsg "$response")
				id="$record_id"
				if [ -n "$record_id" ];then
					echo_date "[update.sh]：${rr}.${domain}更新云解析记录成功"
				else
					echo_date "[update.sh]：${rr}.${domain}更新云解析记录失败, 错误提示 $record_msg"
				fi
			fi
		fi

		new_domain="${new_domain:+$new_domain;}${rr},${domain},${option},${id}"

		# sleep 1
		i=$(($i + 1))
	done
	dbus set aliyddnsv6_domain="${new_domain}"
}

case $1 in # 启动参数
	update)
		start_update | tee -a $logFile # 检查是否有更新
		sh /koolshare/scripts/aliyddnsv6_iptables.sh >/dev/null 2>&1 # 检查防火墙规则及端口转发进程是否存在
	;;
	remove)
		# 取域名数组
		local value="$2"
		local i=0
		local array=$(echo $value | awk -F';' '{print NF-1}')

		while [ $i -le $array ]
		do
			local id=${value%%,*} # 取第1个逗号前
			value=${value#*,} # 截断逗号前字符
			local rr=${value%%,*} # 取第2个逗号前
			value=${value#*,} # 再截断逗号前字符
			local domain=${value%%;*} # 取第3个逗号前
			value=${value#*;} # 再截断逗号前字符
			[ -n "$id" ] && del_record $id >/dev/null 2>&1 && echo_date "[update.sh]：${rr}.${domain}移除云解析记录" | tee -a $logFile
			# sleep 1
			i=$(($i + 1))
		done
	;;
	debug)
		# local response=$(query_record "cd" "jafyang.xyz") # 获取阿里云域名解析记录
		# echo_date "调试原始: $response"
	;;
esac

clean_log | tee -a $logFile # 检查日志数量是否超限