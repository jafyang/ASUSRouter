#!/bin/sh
/koolshare/scripts/nginx_config.sh stop # 停止运行

rm -rf /koolshare/scripts/uninstall_nginx.sh # 删除卸载脚本
rm -rf /koolshare/res/icon-nginx.png # 删除图标
rm -rf /koolshare/scripts/nginx_* # 删除脚本文件
rm -rf /koolshare/webs/Module_nginx.asp # 删除主页
rm -rf /koolshare/init.d/*nginx.sh # 删除启动项
rm -rf /koolshare/bin/nginx # 删除二进制文件
rm -rf /koolshare/bin/php-fpm # 删除二进制文件
rm -rf /koolshare/bin/php8-fpm # 删除二进制文件
rm -rf /tmp/nginx.sock # 删除套接字

#强制删除依赖目录并解除opt路径关联(可能会引发Entware环境)
#rm -rf /tmp/mnt/USB/nginx
#rm -rf /tmp/opt