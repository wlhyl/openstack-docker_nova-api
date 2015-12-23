# image name lzh/nova-api:liberty
FROM 10.64.0.50:5000/lzh/openstackbase:liberty

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-12-23
ENV OPENSTACK_VERSION liberty
ENV BUILD_VERSION 2015-12-23

RUN yum update -y
RUN yum install -y openstack-nova-api iptables
RUN yum clean all
RUN rm -rf /var/cache/yum/*

RUN cp -rp /etc/nova/ /nova
RUN rm -rf /etc/nova/*
RUN rm -rf /var/log/nova/*

VOLUME ["/etc/nova"]
VOLUME ["/var/log/nova"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD nova-api.ini /etc/supervisord.d/nova-api.ini

EXPOSE 8774 8775

ENTRYPOINT ["/usr/bin/entrypoint.sh"]