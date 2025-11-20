#!/bin/sh

source /koolshare/scripts/base.sh
logFile=/tmp/upload/aliyddnsv6_log.txt # 日志记录文件
pidFile="/koolshare/scripts/aliyddnsv6_socat.pid" # 转发进程列表
iptablesFile="/koolshare/scripts/aliyddnsv6_iptables.sh" # 防火墙列表文件
socatFile="/var/log/socat.log" # Socat日志文件
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'
eval $(dbus export aliyddnsv6_)

start_aliyddnsv6(){ # 启动服务
	# 删除转发进程列表及防火墙规则
	if [ -f "$pidFile" ]; then
		cat "$pidFile" | while read line
		do
			if [ -n "$line" ];then
				local tcp=$(echo $line | awk -F',' '{print $1}')
				local port=$(echo $line | awk -F',' '{print $2}')
				local pid=$(echo $line | awk -F',' '{print $3}')

				[ "$tcp" = "TCP4" ] && iptables -t filter -C INPUT -p tcp --dport $port -j ACCEPT && iptables -t filter -D INPUT -p tcp --dport $port -j ACCEPT #检查防火墙规则是否存在并删除
				[ "$tcp" = "TCP4" ] && [ -n "$pid" ] && (netstat -anp | grep "^tcp.*0.0.0.0:$port.*$pid\/socat$" >/dev/null 2>&1) && kill -9 "$pid" && echo_date "[config.sh]：关闭转发进程：$tcp -> $pid" #检查进程是否存在并结束
				[ "$tcp" = "TCP6" ] || [ "$tcp" = "TCP64" ] && ip6tables -t filter -C INPUT -p tcp --dport $port -j ACCEPT && ip6tables -t filter -D INPUT -p tcp --dport $port -j ACCEPT #检查防火墙规则是否存在并删除
				[ "$tcp" = "TCP6" ] || [ "$tcp" = "TCP64" ] && [ -n "$pid" ] && (netstat -anp | grep "^tcp.*:::$port.*$pid\/socat$" >/dev/null 2>&1) && kill -9 "$pid" && echo_date "[config.sh]：关闭转发进程：$tcp -> $pid" #检查进程是否存在并结束
				sleep 1
			fi
		done
	fi

	echo "" > "$pidFile" # 清空任务列表文件
	echo "" > "$iptablesFile" # 清空防火墙列表文件
	echo "" > "$socatFile" # 清空Socat日志文件

	(cru a aliyddnsv6Timer "*/$aliyddnsv6_interval * * * * /koolshare/scripts/aliyddnsv6_update.sh update") && echo_date "[config.sh]：创建定时时钟任务"
	[ "$aliyddnsv6_restart" = "1" ] && local define="dbus set aliyddnsv6_enable=\"1\"" && echo_date "[config.sh]：设置启动项为强制启动"
	(echo -e "#!/bin/sh\n\n${define:+$define\n}sh /koolshare/scripts/aliyddnsv6_config.sh \$1" > /koolshare/init.d/S98aliyddnsv6.sh) && chmod 755 /koolshare/init.d/S98aliyddnsv6.sh >/dev/null 2>&1 # 创建开机启动项
	(echo -e "#!/bin/sh\n\n${define:+$define\n}sh /koolshare/scripts/aliyddnsv6_config.sh \$1" > /koolshare/init.d/N98aliyddnsv6.sh) && chmod 755 /koolshare/init.d/N98aliyddnsv6.sh >/dev/null 2>&1 # 创建恢复启动项

	[ -n "$aliyddnsv6_remove" ] && (sh /koolshare/scripts/aliyddnsv6_update.sh remove $aliyddnsv6_remove >/dev/null 2>&1) && dbus set aliyddnsv6_remove="" # 移除阿里云DDNS解析记录
	sh /koolshare/scripts/aliyddnsv6_update.sh update >/dev/null 2>&1 # 更新阿里云DDNS解析记录


	# 创建转发进程脚本
	local value=$aliyddnsv6_socat
	local i=0
	local array=$(echo $value | awk -F';' '{print NF-1}')
	while [ $i -le $array ]
		do
		local name=${value%%,*} #取第1个逗号前
		value=${value#*,} #截断逗号前字符
		local option=${value%%,*} #取第2个逗号前
		value=${value#*,} #截断逗号前字符
		local wport=${value%%,*} #取第3个逗号前
		value=${value#*,} #再截断逗号前字符
		local nport=${value%%,*} #取第4个逗号前
		value=${value#*,} #再截断逗号前字符
		local ipv4=${value%%;*}  #取分号前
		value=${value#*;} # #再截断逗号前字符

		[ "$option" = "1" ] && (echo "iptables -C INPUT -p tcp --dport ${wport} -j ACCEPT || iptables -I INPUT -p tcp --dport ${wport} -j ACCEPT && (netstat -anp | grep '^tcp.*0.0.0.0:${wport}.*0.0.0.0:*.*LISTEN.*/socat' >/dev/null 2>&1) || (nohup socat -d -d -lf $socatFile TCP4-LISTEN:${wport},reuseaddr,fork TCP4:${ipv4}:${nport} & echo TCP4,${wport},\$! >> $pidFile)" >> "$iptablesFile") && echo_date "[config.sh]：创建转发任务: TCP4:${wport} -> TCP4:${ipv4}:${nport}"
		[ "$option" = "2" ] && (echo "ip6tables -C INPUT -p tcp --dport ${wport} -j ACCEPT || ip6tables -I INPUT -p tcp --dport ${wport} -j ACCEPT && (netstat -anp | grep '^tcp.*:::${wport}.*:::*.*LISTEN.*/socat' >/dev/null 2>&1) || (nohup socat -d -d -lf $socatFile TCP6-LISTEN:${wport},ipv6-v6only=1,reuseaddr,fork TCP4:${ipv4}:${nport} & echo TCP6,${wport},\$! >> $pidFile)" >> "$iptablesFile") && echo_date "[config.sh]：创建转发任务: TCP6:${wport} -> TCP4:${ipv4}:${nport}"
		[ "$option" = "3" ] && (echo "ip6tables -C INPUT -p tcp --dport ${wport} -j ACCEPT || ip6tables -I INPUT -p tcp --dport ${wport} -j ACCEPT && (netstat -anp | grep '^tcp.*:::${wport}.*:::*.*LISTEN.*/socat' >/dev/null 2>&1) || (nohup socat -d -d -lf $socatFile TCP6-LISTEN:${wport},ipv6-v6only=0,reuseaddr,fork TCP4:${ipv4}:${nport} & echo TCP64,${wport},\$! >> $pidFile)" >> "$iptablesFile") && echo_date "[config.sh]：创建转发任务: TCP64:${wport} -> TCP4:${ipv4}:${nport}"

		sleep 1
		i=$(($i + 1))
	done

	chmod 755 "$iptablesFile" >/dev/null 2>&1 # 修改文件执行权限
	sh "$iptablesFile" >/dev/null 2>&1 # 添加防火墙规则及转发进程
	echo_date "[config.sh]：阿里云解析服务已启动"
}

stop_aliyddnsv6(){ # 停止服务
	[ -n "$(cru l | grep aliyddnsv6Timer)" ] && (sed -i '/aliyddnsv6Timer/d' /var/spool/cron/crontabs/* >/dev/null 2>&1) && echo_date "[config.sh]：删除定时时钟任务"

	# 删除转发进程列表及防火墙规则
	if [ -f "$pidFile" ]; then
		cat "$pidFile" | while read line
		do
			if [ -n "$line" ];then
				local tcp=$(echo $line | awk -F',' '{print $1}')
				local port=$(echo $line | awk -F',' '{print $2}')
				local pid=$(echo $line | awk -F',' '{print $3}')

				[ "$tcp" = "TCP4" ] && iptables -t filter -C INPUT -p tcp --dport $port -j ACCEPT && iptables -t filter -D INPUT -p tcp --dport $port -j ACCEPT
				[ "$tcp" = "TCP4" ] && [ -n "$pid" ] && (netstat -anp | grep "^tcp.*0.0.0.0:$port.*$pid\/socat$" >/dev/null 2>&1) && kill -9 "$pid" && echo_date "[config.sh]：关闭转发进程：$tcp -> $pid"
				[ "$tcp" = "TCP6" ] || [ "$tcp" = "TCP64" ] && ip6tables -t filter -C INPUT -p tcp --dport $port -j ACCEPT && ip6tables -t filter -D INPUT -p tcp --dport $port -j ACCEPT
				[ "$tcp" = "TCP6" ] || [ "$tcp" = "TCP64" ] && [ -n "$pid" ] && (netstat -anp | grep "^tcp.*:::$port.*$pid\/socat$" >/dev/null 2>&1) && kill -9 "$pid" && echo_date "[config.sh]：关闭转发进程：$tcp -> $pid"
				sleep 1
			fi
		done
	fi

	# 删除相关文件
	rm -rf "$pidFile" >/dev/null 2>&1
	rm -rf "$iptablesFile" >/dev/null 2>&1
	rm -rf "$socatFile" >/dev/null 2>&1

	# 移除所有云解析记录
	if [ -n "$aliyddnsv6_domain" ]; then
		# 取域名数组
		local value=${aliyddnsv6_domain}
		local remove=""
		local i=0
		local array=$(echo $value | awk -F';' '{print NF-1}')

		while [ $i -le $array ]
		do
			local rr=${value%%,*} # 取第1个逗号前
			value=${value#*,} # 截断逗号前字符
			local domain=${value%%,*} # 取第2个逗号前
			value=${value#*,} # 再截断逗号前字符
			value=${value#*,} # 再截断逗号前字符
			local id=${value%%;*} # 取分号前
			value=${value#*;} # 再截断逗号前字符
			remove="${remove:+$remove;}${id},${rr},${domain}" # 拼合移除解析记录列表

			sleep 1
			i=$(($i + 1))
		done
		[ -n "$remove" ] && sh /koolshare/scripts/aliyddnsv6_update.sh remove $remove >/dev/null 2>&1 # 移除阿里云DDNS解析记录
	fi
	dbus remove aliyddnsv6_last_act
	dbus remove aliyddnsv6_ipv6
	dbus remove aliyddnsv6_ipv4
	echo_date "[config.sh]：阿里云解析服务已关闭"
}

case $1 in # 启动项任务通知
	start)
		if [ "${aliyddnsv6_enable}" == "1" ]; then
			logger "[软件中心]: 正在启动阿里云域名解析服务"
			echo_date "====== AliyunDDNS - WAN拨号触发启动 ======" | tee -a $logFile
			start_aliyddnsv6 | tee -a $logFile
		else
			logger "[软件中心]: 阿里云域名解析服务未设置开机启动，跳过"
		fi
	;;
	stop)
		stop_aliyddnsv6 | tee -a $logFile
	;;
	start_nat)
		if [ "${aliyddnsv6_enable}" == "1" ]; then
			logger "[软件中心]: 正在检查阿里云域名解析服务"
			echo_date "[config.sh]：阿里云域名解析服务正在检查防火墙设置" | tee -a $logFile
			sh "$iptablesFile" >/dev/null 2>&1 # 检查防火墙规则及转发进程
		else
			logger "[软件中心]: 阿里云域名解析服务未设置启动，跳过"
		fi

	;;
	update)
		echo_date "====== AliyunDDNS - 更新成功 ======" | tee -a $logFile
		[ "${aliyddnsv6_enable}" == "1" ] && start_aliyddnsv6 | tee -a $logFile # 更新重启服务
	;;

esac


case $2 in # 网页前端操作通知
	1)
		if [ "${aliyddnsv6_enable}" == "1" ]; then
			echo_date "====== AliyunDDNS - 手动启动 ======" | tee -a $logFile
			start_aliyddnsv6 | tee -a $logFile # 启动服务
		else
			echo_date "====== AliyunDDNS - 手动关闭 ======" | tee -a $logFile
			stop_aliyddnsv6 | tee -a $logFile # 停止服务
		fi
		http_response $1 # 响应回传请求任务Id
		# aliyddnsv6_domain=$(dbus get aliyddnsv6_domain)
		# http_response '{/'\''id/'\'':'$1',/'\''aliyddnsv6_domain/'\'':/'\'$aliyddnsv6_domain'/'\''}' # 响应回传请求任务Id
	;;
	2)
		http_response $1 # 响应回传请求任务Id
		echo "" > $logFile # 清空系统日志
		# http_response '{/'\''id/'\'':'$1'}' # 响应回传请求任务Id
	;;
	3)
		http_response $1 # 响应回传请求任务Id
		sh /koolshare/scripts/aliyddnsv6_update.sh remove $aliyddnsv6_remove >/dev/null 2>&1 # 更新阿里云DDNS解析记录
		dbus remove aliyddnsv6_remove
		# http_response '{/'\''id/'\'':'$1'}' # 响应回传请求任务Id
	;;
esac