#!/bin/sh

sh /koolshare/scripts/easytier_config.sh stop # 停止运行

rm -rf /koolshare/scripts/uninstall_easytier.sh # 删除卸载脚本
rm -rf /koolshare/res/icon-easytier.png # 删除图标
rm -rf /koolshare/scripts/easytier_* # 删除脚本文件
rm -rf /koolshare/webs/Module_easytier.asp # 删除主页
rm -rf /koolshare/init.d/*easytier.sh # 删除启动项
rm -rf /koolshare/bin/easytier* # 删除二进制文件