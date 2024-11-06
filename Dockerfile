FROM debian

RUN apt-get update
RUN apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php* libgd-dev
RUN apt-get install -y openssl libssl-dev
RUN apt-get install -y libmcrypt-dev libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
RUN apt-get install -y inetutils-ping vim
RUN chmod +s /bin/ping

RUN cd /tmp \
	&& wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz \
	&& tar xzf nagioscore.tar.gz

RUN cd /tmp \
	&& wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz \
	&& tar zxf nagios-plugins.tar.gz

RUN cd /tmp/nagioscore-nagios-4.4.14/ \
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

RUN cd /tmp/nagios-plugins-release-2.4.6/ \
	&& ./tools/setup \
	&& ./configure \
	&&  make \
	&& make install

ADD objects /usr/local/nagios/etc/objects
COPY start.sh /.
RUN chmod +x start.sh
CMD ["/usr/bin/bash", "/start.sh"]
