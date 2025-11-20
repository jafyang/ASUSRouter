#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'
eval $(dbus export nginx_)

#"nginx_enable","nginx_htpcore","nginx_phpcore","nginx_status","nginx_port","nginx_watchdog","nginx_firewall"

start_nginx(){ # 启动服务
	#检测opt目录是否存在
	if [ ! -d "/opt" ]; then
		local dfinfo=$(df -h)
		local dev=$(echo "${dfinfo}" | grep -w "/jffs" | awk '{print $1}')
		local usb_path=$(echo "${dfinfo}" | grep -w "${dev}" | grep -v "/jffs" | awk '{print $6}')
		[ -d "${usb_path}/nginx/opt" ] && ln -sf ${usb_path}/nginx/opt /tmp/opt && chmod -R 755 ${usb_path}/nginx/opt >/dev/null 2>&1
	fi

	#处理旧防火墙
	echo "${nginx_port}" | awk -F',' '{for(i=1;i<=NF;i++) print $i}' | while read port; do
		iptables -C INPUT -p tcp --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p tcp --dport ${port} -j ACCEPT
		ip6tables -C INPUT -p tcp --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p tcp --dport ${port} -j ACCEPT
	done

	if [ "${nginx_enable}" == "1" ]; then
		[ "${nginx_watchdog}" == "1" ] && (cru a nginxTimer "*/1 * * * * /koolshare/scripts/nginx_config.sh scan") || (cru d nginxTimer) # 恢复定时时钟任务
		killall nginx >/dev/null 2>&1 && sleep 1 # 停止nginx服务
		killall php8-fpm >/dev/null 2>&1 && sleep 1 # 停止php8-fpm服务
		php8-fpm -y php8-fpm -y /opt/etc/php8-fpm.conf & # 启动php8-fpm后台进程
		nginx -c /opt/etc/nginx/nginx.conf & # 启动nginx后台进程
		sleep 1
	fi

	#处理防火墙
	netstat -anp | grep "^tcp.*nginx" | while read -r line; do
		if echo "$line" | grep -q "LISTEN"; then
			local protocol=$(echo "$line" | awk '{print $1}')
			local address=$(echo "$line" | awk '{print $4}')
			if echo "$address" | grep -q "^[0-9.]*:[0-9]*$"; then
				local type="IPv4"
				local port="${address##*:}"
			else
				local type="IPv6"
				local port="${address##*:}"
			fi
			[ "${nginx_firewall}" == "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			[ "${nginx_firewall}" != "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			if [ -z "${allport}" ]; then
				allport="${port}"
			elif echo ",${allport%,}," | grep -v -q ",${port},"; then
				allport="${allport},${port}"
			fi
		fi
		dbus set nginx_port=${allport} #处理变量
	done

	#处理变量
	pidof nginx > /dev/null 2>&1 && pidof php8-fpm > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set nginx_status="${status}"
	dbus set nginx_htpcore=$(nginx -v 2>&1 | awk '{print $3}' | tr '/' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	dbus set nginx_phpcore=$(php8-fpm -v 2>&1 | awk '/^PHP [0-9]/{print $1, $2; exit}' | tr '/' ' ' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
	dbus set nginx_core="$(dbus get nginx_htpcore)<br>$(dbus get nginx_phpcore)"
}

stop_nginx(){ #停止服务
	[ -n "$(cru l | grep nginxTimer)" ] && (cru d nginxTimer) # 删除定时时钟任务

	#处理防火墙
	netstat -anp | grep "^tcp.*nginx" | while read -r line; do
		if echo "$line" | grep -q "LISTEN"; then
			local protocol=$(echo "$line" | awk '{print $1}')
			local address=$(echo "$line" | awk '{print $4}')
			if echo "$address" | grep -q "^[0-9.]*:[0-9]*$"; then
				local type="IPv4"
				local port="${address##*:}"
			else
				local type="IPv6"
				local port="${address##*:}"
			fi
			[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
		fi
	done

	killall nginx >/dev/null 2>&1 # 停止nginx服务
	killall php8-fpm >/dev/null 2>&1 # 停止php8-fpm服务
	dbus set nginx_status="已停止"
	dbus set nginx_watchdog="0"
	dbus set nginx_firewall="0"
	dbus set nginx_port=""
}

scan_nginx(){ #扫描服务
	#处理防火墙
	netstat -anp | grep "^tcp.*nginx" | while read -r line; do
		if echo "$line" | grep -q "LISTEN"; then
			local protocol=$(echo "$line" | awk '{print $1}')
			local address=$(echo "$line" | awk '{print $4}')
			if echo "$address" | grep -q "^[0-9.]*:[0-9]*$"; then
				local type="IPv4"
				local port="${address##*:}"
			else
				local type="IPv6"
				local port="${address##*:}"
			fi
			[ "${nginx_firewall}" == "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			[ "${nginx_firewall}" != "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			if [ -z "${allport}" ]; then
				allport="${port}"
			elif echo ",${allport%,}," | grep -v -q ",${port},"; then
				allport="${allport},${port}"
			fi
		fi
		[ "${nginx_port}" != "${allport}" ] && dbus set nginx_port=${allport} #处理变量
	done

	#处理变量
	[ "${nginx_enable}" != "1" ] && dbus set nginx_enable="1"
	[ "${nginx_watchdog}" != "1" ] && dbus set nginx_watchdog="1"
	pidof nginx > /dev/null 2>&1 && pidof php8-fpm > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set nginx_status="${status}"
	pidof nginx > /dev/null 2>&1 && pidof php8-fpm > /dev/null 2>&1 || start_nginx #检查进程不存在时重启
}

case $1 in # 启动项命令
	start)
		start_nginx
	;;
	stop)
		stop_nginx
	;;
	scan)
		scan_nginx
	;;
esac

case $2 in # 网页前端操作通知
	1)
		if [ "${nginx_enable}" == "1" ]; then
			start_nginx #启动服务
		else
			stop_nginx #停止服务
		fi
		http_response $1 # 响应回传请求任务Id
	;;
	*)
		[ "$2" ] && http_response $1 # 响应回传请求任务Id
	;;
esac