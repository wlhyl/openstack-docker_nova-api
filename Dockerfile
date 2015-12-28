# image name lzh/nova-api:liberty
FROM 10.64.0.50:5000/lzh/openstackbase:liberty

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-12-28
ENV OPENSTACK_VERSION liberty
ENV BUID_VERSION 2015-12-28

RUN yum update -y && \
         yum install -y openstack-nova-api iptables && \
         rm -rf /var/cache/yum/*

RUN cp -rp /etc/nova/ /nova && \
         rm -rf /etc/nova/* && \
         rm -rf /var/log/nova/*

VOLUME ["/etc/nova"]
VOLUME ["/var/log/nova"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD nova-api.ini /etc/supervisord.d/nova-api.ini

EXPOSE 8774 8775

ENTRYPOINT ["/usr/bin/entrypoint.sh"]