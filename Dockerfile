# image name lzh/nova-api:kilo
FROM registry.lzh.site:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-07-14
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade && apt-get install nova-api iptables -y && apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN cp -rp /etc/nova/ /nova
RUN rm -rf /var/log/nova/*
RUN rm -rf /var/lib/nova/nova.sqlite

VOLUME ["/etc/nova"]
VOLUME ["/var/log/nova"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD nova-api.conf /etc/supervisor/conf.d/nova-api.conf

EXPOSE 8774 8775

ENTRYPOINT ["/usr/bin/entrypoint.sh"]