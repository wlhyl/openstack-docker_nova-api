#!/bin/bash
#set -e表示一旦脚本中有命令的返回值为非0，则脚本立即退出，后续命令不再执行;
#set -o pipefail表示在管道连接的命令序列中，只要有任何一个命令返回非0值，则整个管道返回非0值，即使最后一个命令返回0.

if [ -z "$NOVA_DBPASS" ];then
  echo "error: NOVA_DBPASS not set"
  exit 1
fi

if [ -z "$NOVA_DB" ];then
  echo "error: NOVA_DB not set"
  exit 1
fi

if [ -z "$RABBIT_HOST" ];then
  echo "error: RABBIT_HOST not set"
  exit 1
fi

if [ -z "$RABBIT_USERID" ];then
  echo "error: RABBIT_USERID not set"
  exit 1
fi

if [ -z "$RABBIT_PASSWORD" ];then
  echo "error: RABBIT_PASSWORD not set"
  exit 1
fi

if [ -z "$KEYSTONE_ENDPOINT" ];then
  echo "error: KEYSTONE_ENDPOINT not set"
  exit 1
fi

if [ -z "$NOVA_PASS" ];then
  echo "error: NOVA_PASS not set. user nova password."
  exit 1
fi

if [ -z "$MY_IP" ];then
  echo "error: MY_IP not set. my_ip use management interface IP address of nova-api."
  exit 1
fi

# GLANCE_ENDPOINT = pillar['glance']['endpoint']
if [ -z "$GLANCE_ENDPOINT" ];then
  echo "error: GLANCE_ENDPOINT not set."
  exit 1
fi

if [ -z "$NEUTRON_ENDPOINT" ];then
  echo "error: NEUTRON_ENDPOINT not set."
  exit 1
fi

if [ -z "$NEUTRON_PASS" ];then
  echo "error: NEUTRON_PASS not set."
  exit 1
fi

if [ -z "$METADATA_PROXY_SHARED_SECRET" ];then
  echo "error: METADATA_PROXY_SHARED_SECRET not set."
  exit 1
fi

CRUDINI='/usr/bin/crudini'

CONNECTION=mysql://nova:$NOVA_DBPASS@$NOVA_DB/nova
if [ ! -f /etc/nova/.complete ];then
    cp -rp /nova/* /etc/nova

    chown nova:nova /var/log/nova/
    
    $CRUDINI --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata

    $CRUDINI --set /etc/nova/nova.conf database connection $CONNECTION

    $CRUDINI --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit

    $CRUDINI --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $RABBIT_HOST
    $CRUDINI --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USERID
    $CRUDINI --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $RABBIT_PASSWORD

    $CRUDINI --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

    $CRUDINI --del /etc/nova/nova.conf keystone_authtoken

    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$KEYSTONE_ENDPOINT:5000
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken auth_url http://$KEYSTONE_ENDPOINT:35357
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken project_name service
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken username nova
    $CRUDINI --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS

    $CRUDINI --set /etc/nova/nova.conf DEFAULT my_ip $MY_IP

    $CRUDINI --set /etc/nova/nova.conf glance host $GLANCE_ENDPOINT

    $CRUDINI --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
    
    $CRUDINI --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
    $CRUDINI --set /etc/nova/nova.conf DEFAULT security_group_api neutron
    $CRUDINI --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSInterfaceDriver
    $CRUDINI --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
    
    $CRUDINI --set /etc/nova/nova.conf neutron url http://${neutron_endpoint}:9696
    $CRUDINI --set /etc/nova/nova.conf neutron auth_strategy keystone
    $CRUDINI --set /etc/nova/nova.conf neutron admin_auth_url http://$KEYSTONE_ENDPOINT:35357/v2.0
    $CRUDINI --set /etc/nova/nova.conf neutron admin_tenant_name service
    $CRUDINI --set /etc/nova/nova.conf neutron admin_username neutron
    $CRUDINI --set /etc/nova/nova.conf neutron admin_password $NEUTRON_PASS
    
    $CRUDINI --set /etc/nova/nova.conf neutron service_metadata_proxy True
    $CRUDINI --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret $METADATA_PROXY_SHARED_SECRET

    touch /etc/nova/.complete
fi
# 同步数据库
echo 'select * from instances limit 1;' | mysql -h$NOVA_DB  -unova -p$NOVA_DBPASS nova
if [ $? != 0 ];then
    su -s /bin/sh -c "nova-manage db sync" nova
fi

/usr/bin/supervisord -n