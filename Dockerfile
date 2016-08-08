FROM ubuntu:latest

MAINTAINER mattrayner

# disable interactive functions. 
ENV DEBIAN_FRONTEND noninteractive

# Install apache, php and supplimentary programs. also remove the list from the apt-get update at the end ;-)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update -y && \
	apt-get install -y apache2 \
	libapache2-mod-php5.6 \
	php5.6-mysql \
	php5.6-gd \
	php-pear \
	php5.6-apc \
	php5.6-mcrypt \
	php5.6-mbstring \
	php5.6-json \
	php5.6-curl \
	curl lynx-cur \
	php5.6 \
	git \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean -y \
	&& php -version

# Force php5.6 for the command line
RUN cp -f /usr/bin/php5.6 /usr/bin/php

# Install composer for PHP dependencies
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Enable apache mods.
RUN a2enmod php5.6
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/5.6/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/5.6/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Copy site into place.
ADD www /var/www

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND

# expose container at port 80
EXPOSE 80