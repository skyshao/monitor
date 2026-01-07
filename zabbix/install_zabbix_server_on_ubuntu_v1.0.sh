#!/bin/bash
# -----------------------------------------
# Description: For Zabbix Install. 
# Author: skyshao
# Date: 2018-12-15
# Mail: 6532077@qq.com
# Update: 2018-12-16
# -----------------------------------------

USAGE() {
  echo "Usage:"
  echo "  $0 系统版本 安装方式(1-Online/2-Offline)"
  echo "Example:"
  echo " $0 7 1"
}

if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
  USAGE
  exit 1
fi

if [ $# != 2 ]; then
  USAGE
  exit 1
fi

# Get parameters
# -----------------------------------------
RELEASE=$1
INSTALL_METHOD=$2
# -----------------------------------------
SCRIPT=`readlink -f $0`
SCRIPT_DIR=`dirname $SCRIPT`
WORK_DIR=$(dirname ${SCRIPT_DIR})
INSTALL_DIR=/usr/local
WEB_USER=www-data
WEB_GROUP=www-data
WEB_ROOT=/var/www/html
MYSQL_DATA=/var/mysql
MYSQL_PASS="sky@123"
MY_IP=`ip address|grep -w inet|grep -v 127.0.0.1|awk '{print $2}'|awk -F'/' '{print $1}'`
# -----------------------------------------

CONFIGURE_RESULT() {
if [ $? == 0 ];then
  echo -e "\033[33m^_^ 配置(configure) 完成。 \033[0m"
  sleep 3
else
  echo -e "\033[5;31m>_< 配置(configure) 错误！\033[0m"
  exit 4
fi
}

INSTALL_RESULT() {
if [ $? == 0 ];then
  echo -e "\033[33m^_^ 编译、安装(make && make install) 完成。 \033[0m"
  sleep 3
else
  echo -e "\033[5;31m>_< 编译、安装(make && make install) 错误！\033[0m"
  exit 5
fi
}

INSTALL_ONLINE() {
ping www.baidu.com -c 3 &> /dev/null
if [ $? -eq 0 ];then
  echo "您的系统为Ubuntu$RELEASE"
  sleep 3
  cp /etc/apt/sources.list{,_lamp_`date +%Y%m%d%H%M%S`_bak}
  cp ${WORK_DIR}/config/ubuntu/sources_${RELEASE}.list /etc/apt/sources.list
  dpkg -l mysql-server
  if [ $? != 0 ];then
    echo -e "\033[1;31mREADME！\033[0m"
    echo -e "\033[33m安装mysql过程中会提示输入新密码，请务必使用该密码：\033[0m""\033[1;31m${MYSQL_PASS} \033[0m"
    read -p "按回车[Enter]后继续..." NULL
  fi
  sudo apt-get update
  sudo apt-get -y install build-essential
  INSTALL_RESULT
  case $RELEASE in
  14)
    sudo apt-get -y install mysql-client mysql-server libmysqld-dev apache2 apache2-utils snmpd libsnmp-dev \
      libicu-dev libxml2-dev libevent-dev libcurl4-gnutls-dev libpcre3-dev
    sudo apt-get -y install software-properties-common apt-transport-https lsb-release ca-certificates
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    # install php7.3
    sudo apt-get -y install --allow-unauthenticated php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-bcmath php7.3-mbstring \
      php7.3-xml php7.3-ldap libapache2-mod-php7.3
    INSTALL_RESULT
    ;;
  16)
    sudo apt-get -y install mysql-client mysql-server libmysqld-dev apache2 apache2-utils snmpd libsnmp-dev \
      libicu-dev libxml2-dev libevent-dev libcurl4-gnutls-dev libpcre3-dev
    sudo apt-get -y install software-properties-common apt-transport-https lsb-release ca-certificates
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    # install php7.3
    sudo apt-get -y install --allow-unauthenticated php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-bcmath php7.3-mbstring \
      php7.3-xml php7.3-ldap php7.3-sqlite3 libapache2-mod-php7.3
    INSTALL_RESULT
    ;;
  18)
    echo -e "\033[5;31m Do not support ！\033[0m"
    exit 2
    sudo apt-get -y install apache2 apache2-dev libssl-dev libbz2-dev libxml2-dev libjpeg-dev libpng-dev libxpm-dev \
      libfreetype6-dev libxslt1-dev libcurl4-gnutls-dev libevent-dev libpcre3-dev \
      mysql-client mysql-server libmysqld-dev
    INSTALL_RESULT
    ;;
  *)
    echo -e "\033[5;31m 请输入正确的系统版本：14/16/18。 \033[0m"
    exit 2
    esac
else
    echo -e "\033[5;31m 无法解析域名，请确认是已连接互联网。"
    exit 2
fi
}

INSTALL_LOCAL() {
if [ ! -d "/media/cdrom/" ]; then
  mkdir -p /media/cdrom
fi
mount /dev/cdrom /media/cdrom
grep ${RELEASE} /media/cdrom/.disk/info &> /dev/null
if [ $? -eq 0 ];then
  echo "您的系统为Ubuntu$RELEASE"
  sleep 3
  cp /etc/apt/sources.list{,_lamp_`date +%Y%m%d%H%M%S`_bak}
  echo ""> /etc/apt/sources.list
  sudo apt-cdrom -m -d=/media/cdrom/ add
  dpkg -l mysql-server
  if [ $? != 0 ];then
    echo -e "\033[1;31mREADME！\033[0m"
    echo -e "\033[33m安装mysql过程中会提示输入新密码，请务必使用该密码：\033[0m""\033[1;31m${MYSQL_PASS} \033[0m"
    read -p "按回车[Enter]后继续..." NULL
  fi
  sudo apt-get update
  sudo apt-get -y install build-essential
  case $RELEASE in
  14)
    sudo apt-get -y install mysql-client mysql-server apache2 apache2-utils
    # php7.3依赖包 
    sudo apt-get -y install fonts-dejavu-core libjbig0 fontconfig-config libfontconfig1 libjpeg-turbo8 \
      libjpeg8 libtiff5 libxpm4 libxslt1.1 php-pear
    INSTALL_RESULT
    # 安装 mysql-devel libxml-dev libsnmp-dev
    dpkg -i --force-all ${WORK_DIR}/software/ubuntu14/v1/*.deb
    # 安装 php7.3
    dpkg -i ${WORK_DIR}/software/ubuntu14/php7.3/*.deb
    ;;
  16)
    sudo apt-get -y install mysql-client mysql-server apache2 apache2-utils snmpd 
    # php7.3依赖包
    sudo apt-get -y install libjpeg-turbo8 fonts-dejavu-core fontconfig-config libfontconfig1 libjpeg8 \
      libtiff5 libxpm4 libxslt1.1 libcurl3 php-pear
    INSTALL_RESULT
    # 安装 mysql-devel libxml-dev libsnmp-dev
    dpkg -i --force-all ${WORK_DIR}/software/ubuntu16/v1/*.deb
    # 安装 php7.3
    dpkg -i ${WORK_DIR}/software/ubuntu16/php7.3/*.deb
    ;;
  18)
    echo -e "\033[5;31m Do not support ！\033[0m"
    exit 3
    sleep 3
    ;;
  *)
    echo -e "\033[5;31m 请输入正确的系统版本：14/16/18。 \033[0m"
    exit 3
    esac
  else
    echo -e "\033[5;31m 请给服务器挂载相应的系统盘。\033[0m"
    exit 3
  fi
}

KILL_APT() {
APT_ID=`ps -ef | grep apt-get | grep -v grep | awk '{print $2}'`
for ID in ${APT_ID};do
if [ -n ${ID} ];then
  echo -e "\033[33m apt-get正在运行(PID:${ID})，将强制结束该进程 ！(使用 Ctrl+c 强制退出) \033[0m"
  sleep 3
  kill -9 ${ID}
fi
done
}


## step1：安装依赖包
echo -e "\033[1;32m STEP_1：安装依赖包 \033[0m"
case ${INSTALL_METHOD} in
1)
  KILL_APT
  INSTALL_ONLINE
  ;;  
2)
  echo -e "\033[5;31m Do not support ﻾A\033[0m"
  exit 7
  KILL_APT
  INSTALL_LOCAL
  ;;
*)
  echo -e "\033[31m 请输入正确的安装方式(输入"1"或者"2")。\033[0m"
esac

if [ ${INSTALL_METHOD} == 2 ]; then
 umount -lf /media/cdrom
fi


## step2：安装zabbix主程序
echo -e "\033[1;32m STEP_2：安装zabbix主程序 \033[0m"
sleep 3
/usr/sbin/useradd zabbix &> /dev/null
case $? in
1)
  echo -e "\033[5;31m 该系统无法添加zabbix用户。\033[0m"
  exit 3
;;
9)
  echo "用户zabbix已存在。"
;;
*)
  echo "用户zabbix已添加。"
esac

cd ${WORK_DIR}
tar zxf ${WORK_DIR}/software/zabbix-4*.tar.gz
cd zabbix-4*
./configure --prefix=${INSTALL_DIR}/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 \
--with-net-snmp --with-libcurl --with-libxml2
CONFIGURE_RESULT
make install
INSTALL_RESULT

# 配置zabbix服务
mkdir -p /var/log/zabbix/
touch /var/log/zabbix/zabbix_agentd.log
chown zabbix:zabbix /var/log/zabbix/zabbix_agentd.log
cp ${WORK_DIR}/config/zabbix_server /etc/init.d/
cp ${WORK_DIR}/config/zabbix_agentd /etc/init.d/
sed -i "s#DAEMON=/usr/local/sbin#DAEMON=${INSTALL_DIR}/zabbix/sbin#" /etc/init.d/zabbix_server
sed -i "s#DAEMON=/usr/local/sbin#DAEMON=${INSTALL_DIR}/zabbix/sbin#" /etc/init.d/zabbix_agentd
sed -i "s/^# CacheSize=.*/CacheSize=1024M/g" ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf
sed -i "s/^# ValueCacheSize=.*/ValueCacheSize=512M/g" ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf


## step3：配置zabbix web
echo -e "\033[1;32m STEP_3：配置zabbix web \033[0m"
sleep 3
mkdir -p ${WEB_ROOT}/zabbix
cd ${WORK_DIR}/zabbix-4*/frontends/php/
cp -a . ${WEB_ROOT}/zabbix/

# 配置数据库
if [ ${RELEASE} == 14 ];then
service mysql start
service apache2 start
service php-fpm start
else
systemctl start mysql 
systemctl start apache2
systemctl start php-fpm
fi

# 配置数据库
# 清空mysql密码
# mysqladmin -uroot -p"${MYSQL_PASS}" password ''
# 创建数据库并导入数据
mysql -uroot -p"${MYSQL_PASS}" -e "CREATE DATABASE zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p"${MYSQL_PASS}" -e "GRANT all ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
mysql -uroot -p"${MYSQL_PASS}" -e "flush privileges;"
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-4*/database/mysql/schema.sql 
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-4*/database/mysql/images.sql 
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-4*/database/mysql/data.sql

echo -e "\033[33m^_^ Zabbix web 配置完毕。 \033[0m"


## step4：其他配置
echo -e "\033[1;32m STEP_4：其他配置 \033[0m"
sleep 3
# 配置php7
cp ${WORK_DIR}/config/phpinfo.php ${WEB_ROOT}/
cp ${WORK_DIR}/config/rewrite.load /etc/apache2/mods-enabled/

# 配置zabbix-server
sed -i 's/^# DBPassword=.*/DBPassword=zabbix/g' ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf
cp ${WORK_DIR}/config/zabbix.conf.php ${WEB_ROOT}/zabbix/conf/

# 配置php
sed -i "s/post_max_size =.*/post_max_size = 16M/g" /etc/php/7.3/apache2/php.ini
sed -i "s/max_input_time =.*/max_input_time = 300/g" /etc/php/7.3/apache2/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 300/g" /etc/php/7.3/apache2/php.ini
sed -i "s/^;date.timezone =.*$/date.timezone = Asia\/Shanghai/" /etc/php/7.3/apache2/php.ini

# 重启所有服务
if [ ${RELEASE} == 14 ];then
  update-rc.d zabbix_server defaults
  update-rc.d zabbix_agentd defaults
  update-rc.d apache2 defaults
  update-rc.d mysql defaults
  update-rc.d snmpd defaults
  update-rc.d php7.3-fpm defaults
  service zabbix_server restart
  service zabbix_agentd restart
  service apache2 restart
  service mysql restart
  service snmpd restart
  service php7.3-fpm restart
else
  systemctl enable zabbix_server
  systemctl enable zabbix_agentd
  systemctl enable apache2
  systemctl enable mysql
  systemctl enable snmpd
  systemctl enable php7.3-fpm
  systemctl restart zabbix_server
  systemctl restart zabbix_agentd
  systemctl restart apache2
  systemctl restart mysql
  systemctl restart snmpd
  systemctl restart php7.3-fpm
fi

# rm -rf ${WORK_DIR}/zabbix-*

# 安装完成
echo -e "
**********************************************************************************************
* Zabbix的安装目录为：\033[36m${INSTALL_DIR}/zabbix/ \033[0m
* Zabbix的访问地址为：\033[36mhttp://${MY_IP}/zabbix/ \033[0m (Admin/zabbix)
* Zabbix各服务启动方式为：\033[36m 
`if [ ${RELEASE} == 16 ];then 
echo " | systemctl start|stop|restart|status zabbix_server"
echo " | systemctl start|stop|restart|status zabbix_agentd"
echo " | systemctl start|stop|restart|status mysql"
echo " | systemctl start|stop|restart|status apache2"
echo " | systemctl start|stop|restart|status snmpd"
echo " | systemctl start|stop|restart|status php7.3-fpm"
else
echo " | service zabbix_server start|stop|restart|status"
echo " | service zabbix_agentd start|stop|restart|status"
echo " | service mysql start|stop|restart|status"
echo " | service apache2 start|stop|restart|status"
echo " | service snmpd start|stop|restart|status"
echo " | service php7.3-fpm start|stop|restart|status"
fi` \033[0m
**********************************************************************************************" | tee -a /root/.zabbix_info
