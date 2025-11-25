#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=
UI_TYPE=ASUSWRT
FW_TYPE_CODE=
FW_TYPE_NAME=
DIR=$(cd $(dirname $0); pwd)
module=${DIR##*/}

get_model(){
	local ODMPID=$(nvram get odmpid)
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ];then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

get_fw_type() {
	local KS_TAG=$(nvram get extendno|grep koolshare)
	if [ -d "/koolshare" ];then
		if [ -n "${KS_TAG}" ];then
			FW_TYPE_CODE="2"
			FW_TYPE_NAME="koolshare官改固件"
		else
			FW_TYPE_CODE="4"
			FW_TYPE_NAME="koolshare梅林改版固件"
		fi
	else
		if [ "$(uname -o|grep Merlin)" ];then
			FW_TYPE_CODE="3"
			FW_TYPE_NAME="梅林原版固件"
		else
			FW_TYPE_CODE="1"
			FW_TYPE_NAME="华硕官方固件"
		fi
	fi
}

check_jffs(){
	local dfinfo=$(df -h)
	local dev=$(echo "${dfinfo}" | grep -w "/jffs" | awk '{print $1}')
	local space=$(echo "${dfinfo}" | grep -w "/jffs" | awk '{print $4}')
	if [ -n "${dev}" -a "${dev:0:8}" = "/dev/sda" ];then
		echo_date "已挂载JFFS空间"
	else
		exit_install 2
	fi
}

platform_test(){
	local LINUX_VER=$(uname -r|awk -F"." '{print $1$2}')
	if [ -d "/koolshare" -a -f "/usr/bin/skipd" -a "${LINUX_VER}" -ge "41" ];then
		echo_date 机型："${MODEL} ${FW_TYPE_NAME} 符合安装要求，开始安装插件！"
	else
		exit_install 1
	fi
}

get_ui_type(){
	# default value
	[ "${MODEL}" == "RT-AC86U" ] && local ROG_RTAC86U=0
	[ "${MODEL}" == "GT-AC2900" ] && local ROG_GTAC2900=1
	[ "${MODEL}" == "GT-AC5300" ] && local ROG_GTAC5300=1
	[ "${MODEL}" == "GT-AX11000" ] && local ROG_GTAX11000=1
	[ "${MODEL}" == "GT-AXE11000" ] && local ROG_GTAXE11000=1
	[ "${MODEL}" == "GT-AX6000" ] && local ROG_GTAX6000=1
	local KS_TAG=$(nvram get extendno|grep koolshare)
	local EXT_NU=$(nvram get extendno)
	local EXT_NU=$(echo ${EXT_NU%_*} | grep -Eo "^[0-9]{1,10}$")
	local BUILDNO=$(nvram get buildno)
	[ -z "${EXT_NU}" ] && EXT_NU="0" 
	# RT-AC86U
	if [ -n "${KS_TAG}" -a "${MODEL}" == "RT-AC86U" -a "${EXT_NU}" -lt "81918" -a "${BUILDNO}" != "386" ];then
		# RT-AC86U的官改固件，在384_81918之前的固件都是ROG皮肤，384_81918及其以后的固件（包括386）为ASUSWRT皮肤
		ROG_RTAC86U=1
	fi
	# GT-AC2900
	if [ "${MODEL}" == "GT-AC2900" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AC2900从386.1开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAC2900=0
	fi
	# GT-AX11000
	if [ "${MODEL}" == "GT-AX11000" -o "${MODEL}" == "GT-AX11000_BO4" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AX11000从386.2开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAX11000=0
	fi
	# GT-AXE11000
	if [ "${MODEL}" == "GT-AXE11000" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AXE11000从386.5开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAXE11000=0
	fi
	# ROG UI
	if [ "${ROG_GTAC5300}" == "1" -o "${ROG_RTAC86U}" == "1" -o "${ROG_GTAC2900}" == "1" -o "${ROG_GTAX11000}" == "1" -o "${ROG_GTAXE11000}" == "1" -o "${ROG_GTAX6000}" == "1" ];then
		# GT-AC5300、RT-AC86U部分版本、GT-AC2900部分版本、GT-AX11000部分版本、GT-AXE11000官改版本， GT-AX6000 骚红皮肤
		UI_TYPE="ROG"
	fi
	# TUF UI
	if [ "${MODEL}" == "TUF-AX3000" ];then
		# 官改固件，橙色皮肤
		UI_TYPE="TUF"
	fi
}

exit_install(){
	local state=$1
	case $state in
		1)
			echo_date "本插件适用于【koolshare 梅林改/官改 hnd/axhnd/axhnd.675x】固件平台！"
			echo_date "你的固件平台不能安装！！!"
			echo_date "本插件支持机型/平台：https://github.com/koolshare/rogsoft#rogsoft"
			echo_date "退出安装！"
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
		;;
		2)
			echo_date "本插件需保证足够的存储空间，请先安装USB2JFFS插件后再重试！"
			echo_date "退出安装！"
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
		;;
		0|*)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 0
		;;
	esac
}

install_ui(){
	# install different UI
	get_ui_type
	if [ "${UI_TYPE}" == "ROG" ];then
		echo_date "安装ROG皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "TUF" ];then
		echo_date "安装TUF皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
		sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "ASUSWRT" ];then
		echo_date "安装ASUSWRT皮肤！"
		sed -i '/rogcss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
}

install_now(){
	# default value
	local TITLE="Nginx"
	local DESCR="高性能HTTP和反向代理Web服务器搭配PHP服务端脚本语言"
	local PLVER=$(cat ${DIR}/version)

	# stop first
	local ENABLE=$(dbus get ${module}_enable)
	local PID=$(pidof ${module})
	if [ -n "${PID}" ];then
		echo_date "安装前先关闭${TITLE}插件，以保证更新成功！"
		killall ${module} >/dev/null 2>&1
	fi

	# remove some file first
	killall ${module} >/dev/null 2>&1
	find /koolshare/init.d/ -name "*${module}*"|xargs rm -rf >/dev/null 2>&1
	find /koolshare/bin/ -name "*${module}*"|xargs rm -rf >/dev/null 2>&1

	# make lib directory
	echo_date "创建映像目录..."
	local dfinfo=$(df -h)
	local dev=$(echo "${dfinfo}" | grep -w "/jffs" | awk '{print $1}')
	local usb_path=$(echo "${dfinfo}" | grep -w "${dev}" | grep -v "/jffs" | awk '{print $6}')
	if [ ! -d "/opt" ];then
		[ ! -d "${usb_path}/${module}/opt" ] && mkdir -p "${usb_path}/${module}/opt/" && ln -sf ${usb_path}/${module}/opt /tmp/opt && chmod -R 755 ${usb_path}/${module}/opt >/dev/null 2>&1
	fi
	[ ! -d "/opt/etc" ] && mkdir -p "/opt/etc/" && chmod -R 755 /opt/etc/
	[ ! -d "/opt/lib" ] && mkdir -p "/opt/lib/" && chmod -R 755 /opt/lib/

	# install file
	echo_date "安装插件相关文件..."
	cd /tmp
	cp -rf /tmp/${module}/bin/* /koolshare/bin/
	cp -rf /tmp/${module}/res/* /koolshare/res/
	cp -rf /tmp/${module}/scripts/* /koolshare/scripts/
	cp -rf /tmp/${module}/webs/* /koolshare/webs/
	cp -rf /tmp/${module}/uninstall.sh /koolshare/scripts/uninstall_${module}.sh
	cp -rf /tmp/${module}/opt/* /opt/
	cd /koolshare/bin
	ln -sf php8-fpm php-fpm

	# Permissions
	echo_date "设置文件权限..."
	chmod 755 /koolshare/bin/nginx >/dev/null 2>&1
	chmod 755 /koolshare/bin/php8-fpm >/dev/null 2>&1
	chmod 755 /koolshare/scripts/${module}_*.sh >/dev/null 2>&1
	chmod 755 /koolshare/scripts/uninstall_${module}.sh >/dev/null 2>&1
	chmod 644 /opt/etc/php.ini >/dev/null 2>&1
	chmod 644 /opt/etc/nsswitch.conf >/dev/null 2>&1
	chmod -R 644 /opt/etc/nginx >/dev/null 2>&1
	chmod -R 644 /opt/etc/php8 >/dev/null 2>&1
	chmod -R 644 /opt/etc/php8-fpm.d >/dev/null 2>&1
	chmod -R 644 /opt/etc/ssl >/dev/null 2>&1
	find /opt/var -type d -exec chmod 755 {} \; >/dev/null 2>&1
	find /opt/etc/www -type d -exec chmod 755 {} \; >/dev/null 2>&1
	find /opt/etc/www -type f -exec chmod 644 {} \; >/dev/null 2>&1

	# install library
	echo_date "安装插件相关依赖..."
	cd /opt/lib
	[ ! -L "ld-linux-aarch64.so.1" -a -f "ld-2.27.so" ] && ln -sf ld-2.27.so ld-linux-aarch64.so.1
	[ ! -L "libc.so.6" -a -f "libc-2.27.so" ] && ln -sf libc-2.27.so libc.so.6
	[ ! -L "libcurl.so.4" -a -f "libcurl.so.4.8.0" ] && ln -sf libcurl.so.4.8.0 libcurl.so.4
	[ ! -L "libcrypt.so.1" -a -f "libcrypt-2.27.so" ] && ln -sf libcrypt-2.27.so libcrypt.so.1
	[ ! -L "libdl.so.2" -a -f "libdl-2.27.so" ] && ln -sf libdl-2.27.so libdl.so.2
	[ ! -L "libiconv.so.2" -a -f "libiconv.so.2.7.0" ] && ln -sf libiconv.so.2.7.0 libiconv.so.2
	[ ! -L "libm.so.6" -a -f "libm-2.27.so" ] && ln -sf libm-2.27.so libm.so.6
	[ ! -L "libnettle.so.8" -a -f "libnettle.so.8.10" ] && ln -sf libnettle.so.8.10 libnettle.so.8
	[ ! -L "libnss_files.so.2" -a -f "libnss_files-2.27.so" ] && ln -sf libnss_files-2.27.so libnss_files.so.2
	[ ! -L "libpcre2-8.so.0" -a -f "libpcre2-8.so.0.11.2" ] && ln -sf libpcre2-8.so.0.11.2 libpcre2-8.so.0
	[ ! -L "libpcre2-8.so" -a -L "libpcre2-8.so.0" ] && ln -sf libpcre2-8.so.0 libpcre2-8.so
	[ ! -L "libpthread.so.0" -a -f "libpthread-2.27.so" ] && ln -sf libpthread-2.27.so libpthread.so.0
	[ ! -L "libresolv.so.2" -a -f "libresolv-2.27.so" ] && ln -sf libresolv-2.27.so libresolv.so.2
	[ ! -L "libstdc++.so.6" -a -f "libstdc++.so.6.0.25" ] && ln -sf libstdc++.so.6.0.25 libstdc++.so.6
	[ ! -L "libutil.so.1" -a -f "libutil-2.27.so" ] && ln -sf libutil-2.27.so libutil.so.1
	[ ! -L "libxml2.so.2" -a -f "libxml2.so.2.13.6" ] && ln -sf libxml2.so.2.13.6 libxml2.so.2
	[ ! -L "libz.so.1" -a -f "libz.so.1.3.1" ] && ln -sf libz.so.1.3.1 libz.so.1
	[ ! -L "libz.so" -a -L "libz.so.1" ] && ln -sf libz.so.1 libz.so
	#[ ! -L "" -a -f "" ] && ln -sf
	chmod -R 755 /opt/lib >/dev/null 2>&1

	# check user and group
	[ ! -L "/opt/etc/passwd" ] && ln -sf /etc/passwd /opt/etc/passwd && chmod 644 /opt/etc/passwd >/dev/null 2>&1
	[ ! -L "/opt/etc/group" ] && ln -sf /etc/group /opt/etc/group && chmod 644 /opt/etc/group >/dev/null 2>&1
	grep -q '^nobody:' /etc/passwd || echo 'nobody:x:65534:65534:nobody:/dev/null:/dev/null' >> /etc/passwd >/dev/null 2>&1
	grep -q '^nobody:' /etc/group || echo 'nobody:*:65534:' >> /etc/group >/dev/null 2>&1

	# make start up script link
	echo_date "创建启动项..."
	if [ ! -L "/koolshare/init.d/S10${module}.sh" -a -f "/koolshare/scripts/${module}_config.sh" ];then
		ln -sf /koolshare/scripts/${module}_config.sh /koolshare/init.d/S10${module}.sh
		chmod 755 /koolshare/init.d/S10${module}.sh >/dev/null 2>&1
	fi

	# install different UI
	install_ui

	# dbus value
	echo_date "设置插件默认参数..."
	dbus set ${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"

	# re-enable
	if [ "${ENABLE}" == "1" -a -f "/koolshare/scripts/${module}_config.sh" ];then
		echo_date "安装完毕，重新启用${TITLE}插件！"
		sh /koolshare/scripts/${module}_config.sh start >/dev/null 2>&1
	fi
	
	# finish
	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	get_model
	get_fw_type
	check_jffs
	platform_test
	install_now
}

install
