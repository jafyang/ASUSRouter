#!/bin/sh

sh /koolshare/scripts/aliyddnsv6_config.sh stop

rm -rf /koolshare/scripts/uninstall_aliyddnsv6.sh # 删除卸载脚本
rm -rf /koolshare/res/icon-aliyddnsv6.png # 删除图标
rm -rf /koolshare/scripts/aliyddnsv6_* # 删除脚本文件
rm -rf /koolshare/webs/Module_aliyddnsv6.asp # 删除主页
rm -rf /koolshare/init.d/*aliyddnsv6.sh # 删除启动项
rm -rf /tmp/upload/aliyddnsv6_*.txt # 删除日志