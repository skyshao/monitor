#!/bin/bash
# -----------------------------------------
# Description: For Zabbix Install. 
# Author: skyshao
# Date: 2018-12-15
# Mail: 6532077@qq.com
# Update: 2021-10-06
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
WEB_USER=apache
WEB_GROUP=apache
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
  echo "您的系统为RHEL$RELEASE/centos$RELEASE"
  sleep 3
  yum clean all
  yum -y groupinstall "development tools"
  INSTALL_RESULT
  case $RELEASE in
  8)
    yum install -y httpd mariadb mariadb-server mysql-devel net-snmp net-snmp-devel \
      mysql-devel libxml2-devel libevent-devel pcre-devel libcurl-devel libxslt
    # 安装php
    yum -y install php php-fpm php-gd php-pdo php-bcmath \
      php-mbstring php-xml php-common php-cli php-json php-mysqlnd php-ldap
    INSTALL_RESULT
    ;;
  7)
    yum install -y httpd mariadb mariadb-server mysql-devel net-snmp net-snmp-devel \
      mysql-devel libxml2-devel libevent-devel pcre-devel libcurl-devel libxslt
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    # 安装php73 
    yum -y install php73-php php73-php-fpm php73-php-gd php73-php-pdo php73-php-bcmath \
      php73-php-mbstring php73-php-xml php73-php-common php73-php-cli php73-php-json php73-php-mysqlnd php73-runtime 
    INSTALL_RESULT
    ;;
  6)
    yum install -y httpd mysql mysql-server mysql-devel net-snmp net-snmp-devel \
      mysql-devel libxml2-devel libevent-devel pcre-devel libcurl-devel libxslt
    rpm -Uvh  https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-6.rpm
    rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
    # 安装php73 
    yum -y install php73-php php73-php-fpm php73-php-gd php73-php-pdo php73-php-bcmath \
      php73-php-mbstring php73-php-xml php73-php-common php73-php-cli php73-php-json php73-php-mysqlnd php73-runtime
    INSTALL_RESULT
    ;;
  *)
    echo -e "\033[5;31m 请输入正确的系统版本：6/7。 \033[0m"
    exit 2
    esac
else
  echo -e "\033[5;31m 无法解析域名，请确认是已连接互联网。\033[0m"
  exit 2
fi
}

INSTALL_LOCAL() {
if [ ! -d "/media/CentOS/" ]; then
  mkdir -p /media/CentOS
fi
mount /dev/sr0 /media/CentOS
ls /media/CentOS|grep -E 'media.repo|EULA' &> /dev/null
if [ $? -eq 0 ];then
  echo "您的系统为RHEL$RELEASE/centos$RELEASE"
  sleep 3
  yum clean all
  if [ $RELEASE != 8 ]; then
  yum -y groupinstall --disablerepo=* --enablerepo=c${RELEASE}-media "development tools"
  INSTALL_RESULT
  fi
  case $RELEASE in
  8)
    if [ ! -d "/media/CentOS/" ]; then
      mkdir -p /media/CentOS
    fi
    umount /media/CentOS
    mount /dev/cdrom /media/CentOS
    yum install -y --disablerepo=* --enablerepo=media-baseos,media-appstream "development tools"
    yum install -y --disablerepo=* --enablerepo=media-baseos,media-appstream httpd mariadb mariadb-server mysql-devel net-snmp net-snmp-devel \
      mysql-devel libxml2-devel libevent-devel pcre-devel libcurl-devel libxslt
    # 安装php
    yum -y install --disablerepo=* --enablerepo=media-baseos,media-appstream php php-fpm php-gd php-pdo php-bcmath \
      php-mbstring php-xml php-common php-cli php-json php-mysqlnd php-ldap
    INSTALL_RESULT
    ;;
  7)
    yum -y install --disablerepo=* --enablerepo=c7-media httpd mariadb mariadb-server mysql-devel \
      mysql-devel net-snmp net-snmp-devel libacl libacl-devel libX11 libXpm libtiff libwebp libjpeg \
      libpng environment-modules scl-utils fontconfig-devel policycoreutils-python libargon2 libxslt
    echo "安装php7依赖包"
    yum --disablerepo=* --enablerepo=c7-media -y install libxml2-devel pcre-devel libcurl-devel
	INSTALL_RESULT
    echo "安装libevent"
    rpm -Uvh --force ${WORK_DIR}/software/centos7/libevent/*.rpm
    echo "安装php7.3"
    rpm -Uvh --force ${WORK_DIR}/software/centos7/php73/*.rpm
    ;;
  6)
    yum -y install --disablerepo=* --enablerepo=c6-media httpd mysql mysql-server mysql-devel \
      mysql-devel net-snmp net-snmp-devel libacl libacl-devel libX11 libXpm libtiff libjpeg libpng \
      environment-modules scl-utils fontconfig-devel policycoreutils-python libxslt
    echo "安装php7依赖包"
    yum --disablerepo=* --enablerepo=c6-media -y install libxml2-devel pcre-devel libcurl-devel 
	INSTALL_RESULT
    echo "安装libevent"
    rpm -Uvh --force ${WORK_DIR}/software/centos6/libevent/*.rpm
    echo "安装php7.3"
    rpm -Uvh --force ${WORK_DIR}/software/centos6/php73/*.rpm
    ;;
  *)
    echo -e "\033[5;31m 请输入正确的系统版本：6/7。 \033[0m"
    exit 3
    esac
  else
    echo -e "\033[5;31m 请给服务器挂载相应的系统盘。\033[0m"
    exit 3
  fi
}

KILL_YUM() {
YUM_ID=`ps -ef | grep yum | grep -v grep | awk '{print $2}'`
for ID in ${YUM_ID};do
if [ -n ${ID} ];then
  echo -e "\033[33m yum进程正在运行(PID:${ID})，将强制结束该进程 ！(使用 Ctrl+c 强制退出) \033[0m"
  sleep 3
  kill -9 ${ID}
fi
done
}


## step1：安装依赖包
echo -e "\033[1;32m STEP_1：安装依赖包 \033[0m"
case ${INSTALL_METHOD} in
1)
  KILL_YUM
  INSTALL_ONLINE
  ;;  
2)
  KILL_YUM
  INSTALL_LOCAL
  ;;
*)
  echo -e "\033[31m 请输入正确的安装方式(输入"1"或者"2")。\033[0m"
esac

if [ ${INSTALL_METHOD} == 2 ]; then
  if [ $RELEASE == 8 ];then
    umount -lf /media/CentOS
  else
   umount -lf /media/CentOS
  fi
fi


## step2：安装zabbix主程序
echo -e "\033[1;32m STEP_2：安装zabbix主程序 \033[0m"
sleep 3
/usr/sbin/groupadd --system zabbix &> /dev/null
/usr/sbin/useradd --system -g zabbix -d /home/zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix &> /dev/null
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

mkdir -m u=rwx,g=rwx,o= -p /home/zabbix &> /dev/null
chown zabbix:zabbix /home/zabbix &> /dev/null

cd ${WORK_DIR}
tar zxf ${WORK_DIR}/software/zabbix-5.*.tar.gz
cd zabbix-5.*
./configure --prefix=${INSTALL_DIR}/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 \
--with-net-snmp --with-libcurl --with-libxml2
CONFIGURE_RESULT
make install
INSTALL_RESULT

# 配置zabbix服务
cp ${WORK_DIR}/zabbix-5.*/misc/init.d/fedora/core/zabbix_server /etc/init.d/
cp ${WORK_DIR}/zabbix-5.*/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
sed -i "s#BASEDIR=.*#BASEDIR=${INSTALL_DIR}/zabbix#" /etc/init.d/zabbix_server 
sed -i "s#BASEDIR=.*#BASEDIR=${INSTALL_DIR}/zabbix#" /etc/init.d/zabbix_agentd 
sed -i "s/^# CacheSize=.*/CacheSize=1024M/g" ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf
sed -i "s/^# ValueCacheSize=.*/ValueCacheSize=512M/g" ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf


## step3：配置zabbix web
echo -e "\033[1;32m STEP_3：配置zabbix web \033[0m"
sleep 3
mkdir -p ${WEB_ROOT}/zabbix
cd ${WORK_DIR}/zabbix-5.*/ui/
cp -a . ${WEB_ROOT}/zabbix/

# 配置数据库
if [ ${RELEASE} == 8 ];then
  echo '[mysqld]'>> /etc/my.cnf
  echo 'innodb_strict_mode=0'>> /etc/my.cnf
fi

if [ ${RELEASE} == 6 ];then
  service mysqld start
else
  systemctl start mariadb
fi

# 配置数据库
# 修改mysql密码
mysqladmin -uroot password "${MYSQL_PASS}"

# 创建数据库并导入数据
mysql -uroot -p"${MYSQL_PASS}" -e "CREATE DATABASE zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p"${MYSQL_PASS}" -e "GRANT all ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
mysql -uroot -p"${MYSQL_PASS}" -e "flush privileges;"
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-5.*/database/mysql/schema.sql 
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-5.*/database/mysql/images.sql 
mysql -uroot -p"${MYSQL_PASS}" zabbix < ${WORK_DIR}/zabbix-5.*/database/mysql/data.sql

echo -e "\033[33m^_^ Zabbix web 配置完毕。 \033[0m"


## step4：其他配置
echo -e "\033[1;32m STEP_4：其他配置 \033[0m"
sleep 3
# 配置php7
cp ${WORK_DIR}/config/phpinfo.php ${WEB_ROOT}/

# 配置zabbix-server
sed -i 's/^# DBPassword=.*/DBPassword=zabbix/g' ${INSTALL_DIR}/zabbix/etc/zabbix_server.conf
cp ${WORK_DIR}/config/zabbix.conf.php ${WEB_ROOT}/zabbix/conf/

# 创建log目录(server端日志默认位于/tmp目录下)
#mkdir -p /var/log/zabbix
#touch /var/log/zabbix/{zabbix_server.log,zabbix_agentd.log}
#chown -R zabbix /var/log/zabbix/

# 配置php
if [ ${RELEASE} == 8 ];then
  sed -i "s/post_max_size =.*/post_max_size = 16M/g" /etc/php.ini
  sed -i "s/max_input_time =.*/max_input_time = 300/g" /etc/php.ini
  sed -i "s/max_execution_time =.*/max_execution_time = 300/g" /etc/php.ini
  sed -i "s/^;date.timezone =.*$/date.timezone = Asia\/Shanghai/" /etc/php.ini
else
  sed -i "s/post_max_size =.*/post_max_size = 16M/g" /etc/opt/remi/php73/php.ini
  sed -i "s/max_input_time =.*/max_input_time = 300/g" /etc/opt/remi/php73/php.ini
  sed -i "s/max_execution_time =.*/max_execution_time = 300/g" /etc/opt/remi/php73/php.ini
  sed -i "s/^;date.timezone =.*$/date.timezone = Asia\/Shanghai/" /etc/opt/remi/php73/php.ini
fi

# 配置snmpd
sed -i 's/com2sec notConfigUser.*/com2sec notConfigUser 127.0.0.1 public/' /etc/snmp/snmpd.conf 
sed -i 's/^access  notConfigGroup.*/access notConfigGroup "" any noauth exact all none none/' /etc/snmp/snmpd.conf
sed -i 's/^#view all.*/view all included .1 80/' /etc/snmp/snmpd.conf

# 重启所有服务
if [ ${RELEASE} == 6 ];then
  chkconfig zabbix_server on
  chkconfig zabbix_agentd on
  chkconfig httpd on
  chkconfig mysqld on
  chkconfig snmpd on
  chkconfig php73-php-fpm on
  service zabbix_server restart
  service zabbix_agentd restart
  service httpd restart
  service mysqld restart
  service snmpd restart
  service php73-php-fpm restart
  service iptables status &> /dev/null
  if [ $? -eq 0 ];then
    IPTABLES=running
  else
    IPTABLES=stopped
  fi
  if [ $IPTABLES == running ];then
    iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
    iptables -I INPUT -p tcp --destination-port 161 -j ACCEPT
    iptables -I INPUT -p tcp --destination-port 3306 -j ACCEPT
    iptables -I INPUT -p tcp --destination-port 10051 -j ACCEPT
    service iptables save
    ip6tables -I INPUT -p tcp --destination-port 80 -j ACCEPT
    ip6tables -I INPUT -p tcp --destination-port 161 -j ACCEPT
    ip6tables -I INPUT -p tcp --destination-port 3306 -j ACCEPT
    ip6tables -I INPUT -p tcp --destination-port 10051 -j ACCEPT
    service ip6tables save
  fi
else
  systemctl enable zabbix_server
  systemctl enable zabbix_agentd
  systemctl enable httpd
  systemctl enable mariadb
  systemctl enable snmpd
  systemctl enable php73-php-fpm
  systemctl restart zabbix_server
  systemctl restart zabbix_agentd
  systemctl restart httpd
  systemctl restart mariadb
  systemctl restart snmpd
  if [ ${RELEASE} == 8 ];then
    systemctl restart php-fpm
  else
    systemctl restart php73-php-fpm
  fi
  systemctl status firewalld &> /dev/null
  if [ $? -eq 0 ];then
    IPTABLES=running
  else
    IPTABLES=stopped
  fi
  if [ $IPTABLES == running ];then
    firewall-cmd --zone=public --add-port=80/tcp
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=161/tcp
    firewall-cmd --zone=public --add-port=161/tcp --permanent
    firewall-cmd --zone=public --add-port=3306/tcp
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --zone=public --add-port=10051/tcp
    firewall-cmd --zone=public --add-port=10051/tcp --permanent
  fi
fi

# rm -rf ${WORK_DIR}/zabbix-5*

# 安装完成
echo -e "
**********************************************************************************************
* 您的SELinux的状态为：\033[36m`getenforce` \033[0m
* 您的防火墙的状态为：\033[36m$IPTABLES \033[0m
* Zabbix的安装目录为：\033[36m${INSTALL_DIR}/zabbix/ \033[0m
* Zabbix的访问地址为：\033[36mhttp://${MY_IP}/zabbix/ \033[0m (Admin/zabbix)
* Zabbix的日志目录为：\033[36m/tmp/ \033[0m
* Zabbix各服务启动方式为：\033[36m 
`if [ ${RELEASE} == 6 ];then 
  echo " | service zabbix_server start|stop|restart|status"
  echo " | service zabbix_agentd start|stop|restart|status"
  echo " | service mysqld start|stop|restart|status"
  echo " | service httpd start|stop|restart|status"
  echo " | service snmpd start|stop|restart|status"
  echo " | service php73-php-fpm start|stop|restart|status"
else
  echo " | systemctl start|stop|restart|status zabbix_server"
  echo " | systemctl start|stop|restart|status zabbix_agentd"
  echo " | systemctl start|stop|restart|status mariadb"
  echo " | systemctl start|stop|restart|status httpd"
  echo " | systemctl start|stop|restart|status snmpd"
  if [ ${RELEASE} == 8 ];then
  echo " | systemctl start|stop|restart|status php-fpm"
  else
  echo " | systemctl start|stop|restart|status php73-php-fpm"
  fi
fi` \033[0m
**********************************************************************************************" | tee -a /root/.zabbix_info
