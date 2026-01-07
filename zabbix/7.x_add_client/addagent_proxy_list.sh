#!/bin/bash
# set -x
# description:  Script for adding zabbix client.
# update 20250424

SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
EXP_FILE="${CWD}/tmp/export_`date +'%Y-%m-%d_%H:%M:%S'`.yaml"

# usage
USAGE() {
  echo "Usage:"
  echo "    $0 "
  echo -e "\033[33m 手动编辑 agent_list 文件，填写“组名|主机名|IP地址|PROXY_NAME”信息。请参考入下示例：\033[0m"
  echo -e "\033[34m vi ${CWD}/agent_list \033[0m"
  echo -e "\033[34m group1|servername1|192.168.1.101|proxy1 \033[0m"
  echo -e "\033[34m group1|servername2|192.168.1.102|proxy1 \033[0m"
  echo -e "\033[34m 更新 template-agent-proxy 配置中 templates name 部分\033[0m"
}

if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
  USAGE
  exit 1
fi

if [ $# -gt 0 ]; then
  USAGE
  exit 1
fi

if [ ! -s ${CWD}/agent_list ]; then
  echo -e "\033[5;31m agent_list文件未配置！\033[0m"
  USAGE
  exit 1
fi

if [ ! -d ${CWD}/tmp/ ];then
  mkdir ${CWD}/tmp/
fi

# start

if [ ! -s ${EXP_FILE} ];then
  touch ${EXP_FILE}
fi

echo "zabbix_export:" > ${EXP_FILE}
echo "  version: '7.0'" >> ${EXP_FILE}
#echo "  date: '`date +'%Y-%m-%dT%H:%M:%SZ'`' " >> ${EXP_FILE}
#echo "  groups:" >> ${EXP_FILE}
#echo "    -" >> ${EXP_FILE}
#echo "      uuid: f005a31237174f8c85946496c4fc2061" >> ${EXP_FILE}
#echo "      name: Templates" >> ${EXP_FILE}
echo "  hosts:" >> ${EXP_FILE}


for HOST in `cat ${CWD}/agent_list`
do
# 直接监控参数为：3，通过zabbix_proxy监控参数为：4
COUNT=`echo ${HOST} | awk -F '|' '{print NF}'`
if [ ${COUNT} != 4 ];then
  USAGE
  exit 1
fi

GROUP_NAME=`echo ${HOST} | awk -F '|' '{print $1}'`
HOST_NAME=`echo ${HOST} | awk -F '|' '{print $2}'`
IP_ADDR=`echo ${HOST} | awk -F '|' '{print $3}'`
PROXY_NAME=`echo ${HOST} | awk -F '|' '{print $4}'`

# 更行输出文件
sed -e "s#GROUP_NAME#${GROUP_NAME}#g" -e "s#IP_ADDR#${IP_ADDR}#g" -e "s#HOST_NAME#${HOST_NAME}#g" -e "s#PROXY_NAME#${PROXY_NAME}#g" ${CWD}/template-agent-proxy | tee -a ${EXP_FILE} &> /dev/null

done

# end
#echo "    </hosts>" >> ${EXP_FILE}
#echo "</zabbix_export>" >> ${EXP_FILE}
