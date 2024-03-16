FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install git apache2 python3 python3-pip python3-ldap rsync ansible python3-requests \
    python3-networkx python3-matplotlib python3-bottle python3-future python3-jinja2 python3-peewee python3-distro \ 
    python3-pymysql python3-psutil netcat-traditional nmap net-tools lshw dos2unix libapache2-mod-wsgi-py3 openssl sshpass \
    python3-flask python3-flask-login python3-flask-caching -y

WORKDIR /var/www/

RUN git clone https://github.com/hap-wi/roxy-wi.git /var/www/haproxy-wi

RUN chown -R www-data:www-data haproxy-wi/
RUN cp haproxy-wi/config_other/httpd/roxy-wi_deb.conf /etc/apache2/sites-available/roxy-wi.conf
RUN a2ensite roxy-wi.conf
RUN a2enmod cgid ssl proxy_http rewrite
RUN pip3 install -r haproxy-wi/config_other/requirements_deb.txt
RUN pip3 install paramiko-ng
RUN chmod +x haproxy-wi/app/create_db.py
RUN cp haproxy-wi/config_other/logrotate/* /etc/logrotate.d/
RUN mkdir /var/lib/roxy-wi/
RUN mkdir /var/lib/roxy-wi/keys/
RUN mkdir /var/lib/roxy-wi/configs/
RUN mkdir /var/lib/roxy-wi/configs/hap_config/
RUN mkdir /var/lib/roxy-wi/configs/kp_config/
RUN mkdir /var/lib/roxy-wi/configs/nginx_config/
RUN mkdir /var/lib/roxy-wi/configs/apache_config/
RUN mkdir /var/log/roxy-wi/
RUN mkdir /etc/roxy-wi/
RUN mv haproxy-wi/roxy-wi.cfg /etc/roxy-wi
RUN openssl req -newkey rsa:4096 -nodes -keyout /var/www/haproxy-wi/app/certs/haproxy-wi.key -x509 -days 10365 -out /var/www/haproxy-wi/app/certs/haproxy-wi.crt -subj "/C=US/ST=Almaty/L=Springfield/O=Roxy-WI/OU=IT/CN=*.roxy-wi.domain.local/emailAddress=email@domain.local"
RUN chown -R www-data:www-data /var/www/haproxy-wi/
RUN chown -R www-data:www-data /var/lib/roxy-wi/
RUN chown -R www-data:www-data /var/log/roxy-wi/
RUN chown -R www-data:www-data /etc/roxy-wi/

WORKDIR /var/www/haproxy-wi/app
USER www-data
RUN ./create_db.py
USER root

COPY httpd-foreground /usr/local/bin/
CMD ["httpd-foreground"]
