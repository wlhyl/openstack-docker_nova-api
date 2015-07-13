# 环境变量
- NOVA_DB: nova数据库IP
- NOVA_DBPASS： novae数据库密码
- NOVA_PASS: openstack nova用户 密码
- RABBIT_HOST: rabbitmq IP
- RABBIT_USERID: rabbitmq user
- RABBIT_PASSWORD: rabbitmq user 的 password
- KEYSTONE_ENDPOINT: keystone endpoint
- MY_IP: my_ip
- GLANCE_ENDPOINT: glance endpoint

# volumes:
- /opt/openstack/nova-api/: /etc/nova
- /opt/openstack/log/nova-api/: /var/log/nova/

# 启动glance
docker run -d --name nova-api -p 8774:8774 \
    -v /opt/openstack/nova-api/:/etc/nova \
    -v /opt/openstack/log/nova-api/:/var/log/nova/ \
    -e NOVA_DB=10.64.0.52 \
    -e NOVA_DBPASS=nova_dbpass \
    -e RABBIT_HOST=10.64.0.52 \
    -e RABBIT_USERID=openstack \
    -e RABBIT_PASSWORD=openstack \
    -e KEYSTONE_ENDPOINT=10.64.0.52 \
    -e MY_IP=10.64.0.52 \
    -e GLANCE_ENDPOINT=10.64.0.52 \
    10.64.0.50:5000/lzh/nova-api:kilo