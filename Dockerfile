FROM ruby:2.6-slim-stretch

ENV TZ="Asia/Tokyo" \
    LANG="ja_JP.UTF-8" \
    LC_CTYPE="ja_JP.UTF-8" \
    REDMINE_LANG="ja" \
    APP_HOME="/var/lib/redmine"

ENV DEBIAN_FRONTEND noninteractive
RUN set -eux; \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    vim \
    \
    bzr \
    openssh-client \
    gsfonts \
    imagemagick libmagick++-dev \
    build-essential \
    libpq-dev \
    apache2 apache2-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev \
    ; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
    gem install passenger -v 6.0.2; \
    passenger-install-apache2-module --auto --languages ruby;

ENV DEBIAN_FRONTEND dialog

RUN : "redmine.conf" && { \
    echo "<VirtualHost *:80>"; \
    echo "ServerName ${HOSTNAME}"; \
    echo "ServerAdmin webmaster@localhost"; \
    echo "DocumentRoot /var/lib/redmine/public"; \
    echo "ErrorLog ${APACHE_LOG_DIR}/error.log"; \
    echo "CustomLog ${APACHE_LOG_DIR}/access.log combined"; \
    echo "#RailsEnv production"; \
    echo "RailsEnv development"; \
    echo "PassengerEnabled on"; \
    echo "<Directory "/var/lib/redmine/public">"; \
    echo "  Require all granted"; \
    echo "</Directory>"; \
    echo "</VirtualHost>"; \
  } | tee /etc/apache2/conf-available/redmine.conf; \
  a2enconf redmine; \
  : "default.comf" && { \
    echo "LoadModule passenger_module /usr/local/bundle/gems/passenger-6.0.2/buildout/apache2/mod_passenger.so"; \
    echo "<IfModule mod_passenger.c>"; \
    echo "  PassengerRoot /usr/local/bundle/gems/passenger-6.0.2"; \
    echo "  PassengerDefaultRuby /usr/local/bin/ruby"; \
    echo "</IfModule>"; \
    echo "PassengerMaxPoolSize 20"; \
    echo "PassengerMaxInstancesPerApp 4"; \
    echo "PassengerPoolIdleTime 864000"; \
    echo "PassengerStatThrottleRate 10"; \
  } | tee /etc/apache2/sites-enabled/000-default.conf;

WORKDIR /tmp
ADD ./Gemfile /tmp
RUN bundle install

WORKDIR $APP_HOME
ADD . $APP_HOME

RUN : "仮のdatabase.ymlを作成" && { \
    echo "production:"; \
    echo "  adapter: postgresql"; \
    echo "development:"; \
    echo "  adapter: postgresql"; \
    echo "test:"; \
    echo "  adapter: postgresql"; \
  } | tee /var/lib/redmine/config/database.yml;

# COPY apache-conf/rm01.conf /etc/apache2/conf-available/
# COPY apache-conf/rm02.conf /etc/apache2/conf-available/
# COPY apache-conf/rm03.conf /etc/apache2/conf-available/
# RUN a2enconf rm01; \
#     a2enconf rm02; \
#     a2enconf rm03;
RUN ln -s $APP_HOME /var/lib/rm01; \
    ln -s $APP_HOME /var/lib/rm02; \
    ln -s $APP_HOME /var/lib/rm03


COPY ./start.sh /
COPY ./entrypoint.sh /
RUN chmod +x /start.sh && \
  chmod +x /entrypoint.sh && \
  bundle update

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
