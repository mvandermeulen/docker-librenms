FROM phusion/baseimage:18.04-1.0.0
LABEL MAINTAINER="seti@setadesign.net"

# Set correct environment variables.
ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LC_ALL=C.UTF-8 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends && \
	echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends && \
        add-apt-repository ppa:ondrej/php -y && \
	apt-get update -q && \
	apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
	apt-get install -y \
		acl composer php7.4-mbstring php7.4-cli php7.4-mysql php7.4-gd \
		php7.4-snmp php-pear php7.4-curl php-memcached \
		php7.4-fpm snmp graphviz php7.4-json php7.4-opcache nginx-full fping \
		imagemagick whois mtr-tiny nmap python-mysqldb snmpd php7.4-ldap \
		python3-pip syslog-ng \
		php-net-ipv6 php-imagick rrdtool rrdcached git at mysql-client \
		nagios-plugins sudo ipmitool unzip \
        memcached php7.4-xml php7.4-zip python-memcache make && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN	useradd librenms -m -r && usermod -a -G librenms www-data && \
	rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh && \
	locale-gen de_DE.UTF-8 && locale-gen en_US.UTF-8 && \
	mkdir -p /data/logs /data/rrd /data/config /run/php /var/run/rrdcached



# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

COPY init.sh /etc/my_init.d/init.sh
COPY php-fpm.sh /etc/service/php-fpm/run
COPY nginx.sh /etc/service/nginx/run
COPY rrdcached.sh /opt/services/rrdcached/run
COPY memcached.sh /opt/services/memcached/run
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

RUN cd /opt && \
	chmod +x /etc/my_init.d/init.sh && \
	chmod +x /etc/service/nginx/run && \
	chmod +x /etc/service/php-fpm/run && \
	chmod +x /opt/services/*/run && \
	chown -R nobody:users /data/config && \
	chown librenms:librenms /var/run/rrdcached && \
	chmod 755 /var/run/rrdcached && \
	chmod u+s /usr/bin/fping && \
	chmod u+s /usr/bin/fping6 && \
	rm -f /etc/nginx/sites-available/default

COPY nginx.conf /etc/nginx/sites-available/default

EXPOSE 80/tcp
# Memcached
EXPOSE 11211/tcp
# RRDCached
EXPOSE 42217/tcp

VOLUME ["/data"]
