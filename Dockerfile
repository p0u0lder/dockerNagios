FROM debian

RUN apt-get update
RUN apt-get install -y inetutils-ping
RUN apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php* libgd-dev
RUN apt-get install -y openssl libssl-dev
RUN cd /tmp \
	&& wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz \
	&& tar xzf nagioscore.tar.gz \
	&& cd /tmp/nagioscore-nagios-4.4.14/ \
	&& ./configure --with-httpd-conf=/etc/apache2/sites-enabled \
	&& make all \
	&& make install-groups-users \
	&& usermod -a -G nagios www-data \
	&& make install \
	&& make install-daemoninit \
	&& make install-commandmode \
	&& make install-config \
	&& make install-webconf \
	&& a2enmod rewrite \
	&& a2enmod cgi \
	&& htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
RUN service apache2 restart \
	&& service apache2 start
RUN apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext \
	&& cd /tmp \
	&& wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz \
	&& tar zxf nagios-plugins.tar.gz \
	&& cd /tmp/nagios-plugins-release-2.4.6/ \
	&& ./tools/setup \
	&& ./configure \
	&&  make \
	&& make install

RUN apt install -y vim

COPY start.sh /.
RUN chmod +x start.sh
CMD ["/usr/bin/bash", "/start.sh"]
