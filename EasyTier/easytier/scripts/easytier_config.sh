#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'
eval $(dbus export easytier_)

start_easytier(){ # 启动服务
	if [ "${easytier_enable}" == "1" ]; then
		[ "${easytier_watchdog}" == "1" ] && (cru a easytierTimer "*/1 * * * * /koolshare/scripts/easytier_config.sh scan") || (cru d easytierTimer) # 创建定时时钟任务
		killall easytier-core > /dev/null 2>&1
		/koolshare/bin/easytier-core -w ${easytier_id} --machine-id $(cat /sys/class/net/br0/address) & #启动后台进程
		sleep 1
		#iptables -C INPUT -p tcp --dport 11010 -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p tcp --dport 11010 -j ACCEPT
		#iptables -C INPUT -p udp --dport 11010 -j ACCEPT 2>/dev/null || iptables -t filter -I INPUT -p udp --dport 11010 -j ACCEPT
		#ip6tables -C INPUT -p tcp --dport 11010 -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p tcp --dport 11010 -j ACCEPT
		#ip6tables -C INPUT -p udp --dport 11010 -j ACCEPT 2>/dev/null || ip6tables -t filter -I INPUT -p udp --dport 11010 -j ACCEPT
	fi
	pidof easytier-core > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set easytier_status="${status}"
	dbus set easytier_core="$(easytier-core -V | awk '{print $2}')"
}

stop_easytier(){ # 停止服务
	[ -n "$(cru l | grep easytierTimer)" ] && (cru d easytierTimer) # 删除定时时钟任务
	killall easytier-core > /dev/null 2>&1 #结束进程
	dbus set easytier_status="已停止"
	dbus set easytier_watchdog="0"
	#iptables -C INPUT -p tcp --dport 11010 -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p tcp --dport 11010 -j ACCEPT
	#iptables -C INPUT -p udp --dport 11010 -j ACCEPT 2>/dev/null && iptables -t filter -D INPUT -p udp --dport 11010 -j ACCEPT
	#ip6tables -C INPUT -p tcp --dport 11010 -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p tcp --dport 11010 -j ACCEPT
	#ip6tables -C INPUT -p udp --dport 11010 -j ACCEPT 2>/dev/null && ip6tables -t filter -D INPUT -p udp --dport 11010 -j ACCEPT

}

scan_easytier(){ # 定时扫描
	[ "${easytier_enable}" != "1" ] && dbus set easytier_enable="1"
	[ "${easytier_watchdog}" != "1" ] && dbus set easytier_watchdog="1"
	pidof easytier-core > /dev/null 2>&1 || start_easytier #检查进程
	pidof easytier-core > /dev/null 2>&1 && status="运行中" || status="已停止"; dbus set easytier_status="${status}"
}

case $1 in # 启动项命令
	start)
		start_easytier
	;;
	stop)
		stop_easytier
	;;
	scan)
		scan_easytier
	;;
esac

case $2 in # 网页前端操作通知
	1)
		if [ "${easytier_enable}" == "1" ]; then
			start_easytier #启动服务
		else
			stop_easytier #停止服务
		fi
		http_response $1 # 响应回传请求任务Id
	;;
	*)
		[ "$2" ] && http_response $1 # 响应回传请求任务Id
	;;
esac
