#!/bin/bash

echo "need run copy_zabbix_agent.sh first ."
sleep 2

SCRIPT=`readlink -f $0`
WORK_DIR=`dirname $SCRIPT`
CLIENT_DIR=zabbix_for_client

for HOST in `cat ${WORK_DIR}/host_list.txt`;do
ssh $HOST /root/${CLIENT_DIR}/add_zabbix_agent.sh $HOST
ssh $HOST touch /tmp/zabbix_agentd.log /tmp/zabbix_agentd.pid
ssh $HOST chown zabbix /tmp/zabbix_agentd.*
ssh $HOST /etc/init.d/zabbix_agentd restart
ssh $HOST ps -elf|grep zabbix
sleep 2
ssh $HOST rm -rf /root/${CLIENT_DIR}/
done
