#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'
eval $(dbus export lighttpd_)

start_lighttpd(){ # 启动服务
	#处理旧防火墙
	echo "${lighttpd_port}" | awk -F',' '{for(i=1;i<=NF;i++) print $i}' | while read port; do
		iptables -C INPUT -p tcp --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p tcp --dport ${port} -j ACCEPT
		ip6tables -C INPUT -p tcp --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p tcp --dport ${port} -j ACCEPT
	done

	if [ "${lighttpd_enable}" == "1" ]; then
		[ "${lighttpd_watchdog}" == "1" ] && (cru a lighttpdTimer "*/1 * * * * /koolshare/scripts/lighttpd_config.sh scan") || (cru d lighttpdTimer) # 恢复定时时钟任务
		killall lighttpd >/dev/null 2>&1 && sleep 1 # 停止lighttpd服务
		lighttpd -f /koolshare/configs/lighttpd/lighttpd.conf & # 启动后台进程
		sleep 1
	fi

	#处理防火墙
	netstat -anp | grep "lighttpd" | while read -r line; do
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
			[ "${lighttpd_firewall}" == "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			[ "${lighttpd_firewall}" != "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			if [ -z "${allport}" ]; then
				allport="${port}"
			elif echo ",${allport%,}," | grep -v -q ",${port},"; then
				allport="${allport},${port}"
			fi
		fi
		dbus set lighttpd_port=${allport} #处理变量
	done

	#处理变量
	pidof lighttpd > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set lighttpd_status="${status}"
	dbus set lighttpd_core=$(lighttpd -v 2>&1 | awk '/^lighttpd\//{print $1}')
}

stop_lighttpd(){ # 停止服务
	[ -n "$(cru l | grep lighttpdTimer)" ] && (cru d lighttpdTimer) # 删除定时时钟任务

	#处理防火墙
	netstat -anp | grep "lighttpd" | while read -r line; do
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

	killall lighttpd >/dev/null 2>&1 # 停止lighttpd服务
	dbus set lighttpd_status="已停止"
	dbus set lighttpd_watchdog="0"
	dbus set lighttpd_firewall="0"
	dbus set lighttpd_port=""
}

scan_lighttpd(){ # 定时扫描
	#处理防火墙
	netstat -anp | grep "lighttpd" | while read -r line; do
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
			[ "${lighttpd_firewall}" == "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			[ "${lighttpd_firewall}" != "1" ] && {
				[ $type = "IPv4" ] && (iptables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
				[ $type = "IPv6" ] && (ip6tables -C INPUT -p ${protocol} --dport ${port} -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p ${protocol} --dport ${port} -j ACCEPT)
			}
			if [ -z "${allport}" ]; then
				allport="${port}"
			elif echo ",${allport%,}," | grep -v -q ",${port},"; then
				allport="${allport},${port}"
			fi
		fi
		[ "${lighttpd_port}" != "${allport}" ] && dbus set lighttpd_port=${allport} #处理变量
	done

	#处理变量
	[ "${lighttpd_enable}" != "1" ] && dbus set lighttpd_enable="1"
	[ "${lighttpd_watchdog}" != "1" ] && dbus set lighttpd_watchdog="1"
	pidof lighttpd > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set lighttpd_status="${status}"
	pidof lighttpd > /dev/null 2>&1 || start_lighttpd #检查进程不存在时重启
}

case $1 in # 启动项命令
	start)
		start_lighttpd
	;;
	stop)
		stop_lighttpd
	;;
	scan)
		scan_lighttpd
	;;
esac

case $2 in # 网页前端操作通知
	1)
		if [ "${lighttpd_enable}" == "1" ]; then
			start_lighttpd #启动服务
		else
			stop_lighttpd #停止服务
		fi
		http_response $1 # 响应回传请求任务Id
	;;
	*)
		[ "$2" ] && http_response $1 # 响应回传请求任务Id
	;;
esac