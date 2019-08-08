FROM ruby:2.6.3-slim-stretch

ENV TZ="Asia/Tokyo" \
    LANG="ja_JP.UTF-8" \
    LC_CTYPE="ja_JP.UTF-8" \
    REDMINE_LANG="ja" \
    APP_HOME="/var/lib/redmine"

RUN groupadd -r redmine && useradd -r -g redmine redmine

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

RUN mkdir -p /tmp/config; \
    : "仮のdatabase.ymlを作成" && { \
    echo "production:"; \
    echo "  adapter: postgresql"; \
    echo "development:"; \
    echo "  adapter: postgresql"; \
    echo "test:"; \
    echo "  adapter: postgresql"; \
  } | tee /tmp/config/database.yml;

WORKDIR /tmp
COPY ./Gemfile /tmp
RUN bundle install; \
    gem install aws-sdk

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

RUN chown redmine:redmine "$APP_HOME"; \
    chmod 1777 "$APP_HOME"; \
    chmod -R ugo=rwX config db; \
	  find log tmp -type d -exec chmod 1777 '{}' +

RUN : "redmine.conf" && { \
    echo "<VirtualHost *:80>"; \
    echo "ServerName ${HOSTNAME}"; \
    echo "ServerAdmin webmaster@localhost"; \
    echo "DocumentRoot /var/lib/redmine/public"; \
    echo "ErrorLog /var/log/apache2/error.log"; \
    echo "CustomLog /var/log/apache2/access.log vhost_combined"; \
    echo "RailsEnv production"; \
    echo "#RailsEnv development"; \
    echo "PassengerEnabled on"; \
    echo "<Directory "/var/lib/redmine/public">"; \
    echo "  Require all granted"; \
    echo "</Directory>"; \
    echo "</VirtualHost>"; \
  } | tee /etc/apache2/conf-available/000-default.conf; \
  a2enconf 000-default; \
  : "default.comf" && \
  passenger-install-apache2-module --snippet | tee /etc/apache2/sites-enabled/passenger.conf;

COPY ./start.sh /
COPY ./entrypoint.sh /
COPY ./entrypoint.rb /
RUN chmod +x /start.sh && \
  chmod +x /entrypoint.sh && \
  chmod +x /entrypoint.rb && \
  bundle install

EXPOSE 3000
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
