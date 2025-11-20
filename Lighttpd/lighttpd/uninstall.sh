#!/bin/sh

sh /koolshare/scripts/lighttpd_config.sh stop # 停止运行

rm -rf /koolshare/scripts/uninstall_lighttpd.sh # 删除卸载脚本
rm -rf /koolshare/res/icon-lighttpd.png # 删除图标
rm -rf /koolshare/configs/lighttpd # 删除配置
rm -rf /koolshare/scripts/lighttpd_* # 删除脚本文件
rm -rf /koolshare/webs/Module_lighttpd.asp # 删除主页
rm -rf /koolshare/init.d/*lighttpd.sh # 删除启动项
rm -rf /koolshare/bin/lighttpd # 删除二进制文件