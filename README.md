# 环境变量
- NOVA_DB: nova数据库IP
- NOVA_DBPASS： novae数据库密码
- RABBIT_HOST: rabbitmq IP
- RABBIT_USERID: rabbitmq user
- RABBIT_PASSWORD: rabbitmq user 的 password
- MY_IP: my_ip
- KEYSTONE_ADMIN_ENDPOINT: keystone admin endpoint
- KEYSTONE_INTERNAL_ENDPOINT: keystone internal endpoint
- NEUTRON_INTERNAL_ENDPOINT: neutron internal endpoint
- NEUTRON_PASS: openstack neutron password
- GLANCE_HOST: glance internal_endpoint

# volumes:
- /opt/openstack/nova-api/: /etc/nova
- /opt/openstack/log/nova-api/: /var/log/nova/

# 启动nova-api
```bash
docker run -d --name nova-api \
    -p 8774:8774 \
    -p 8775:8775 \
    -v /opt/openstack/nova-api/:/etc/nova \
    -v /opt/openstack/log/nova-api/:/var/log/nova/ \
    -e NOVA_DB=10.64.0.52 \
    -e NOVA_DBPASS=nova_dbpass \
    -e RABBIT_HOST=10.64.0.52 \
    -e RABBIT_USERID=openstack \
    -e RABBIT_PASSWORD=openstack \
    -e KEYSTONE_ADMIN_ENDPOINT=10.64.0.52 \
    -e KEYSTONE_INTERNAL_ENDPOINT=10.64.0.52 \
    -e MY_IP=10.64.0.52 \
    -e GLANCE_INTERNAL_ENDPOINT=10.64.0.52 \
    -e NEUTRON_INTERNAL_ENDPOINT=10.64.0.52 \
    -e NEUTRON_PASS=neutron_pass \
    10.64.0.50:5000/lzh/nova-api:kilo
```