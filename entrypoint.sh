#!/bin/bash

{ \
    echo "production:"; \
    echo "  adapter: postgresql"; \
    echo "  database: <%= ENV['RAILS_DB'] %>"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
    echo "development:"; \
    echo "  adapter: postgresql"; \
    echo "  database: <%= ENV['RAILS_DB'] %>_development"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
    echo "test:"; \
    echo "  adapter: postgresql"; \
    echo "  database: <%= ENV['RAILS_DB'] %>_test"; \
    echo "  username: <%= ENV['RAILS_DB_USERNAME'] %>"; \
    echo "  password: <%= ENV['RAILS_DB_PASSWORD'] %>"; \
    echo "  host: <%= ENV['RAILS_DB_HOST'] %>"; \
    echo "  encoding: <%= ENV['RAILS_DB_ENCODING'] %>"; \
} | tee /var/lib/redmine/config/database.yml

{ \
    echo "production:"; \
    echo "  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>"; \
    echo "  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>"; \
    echo "  bucket: <%= ENV['S3_BUCKET_NAME'] %>"; \
    echo "  folder: <%= ENV['S3_FOLDER_NAME'] %>"; \
    echo "  endpoint: <%= ENV['S3_ENDPOINT'] %>"; \
    echo "  secure: true"; \
    echo "  private: true"; \
    echo "  expires:"; \
    echo "  proxy: false"; \
    echo "  thumb_folder:"; \
    echo "development:"; \
    echo "  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>"; \
    echo "  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>"; \
    echo "  bucket: <%= ENV['S3_BUCKET_NAME'] %>"; \
    echo "  folder: <%= ENV['S3_FOLDER_NAME'] %>"; \
    echo "  endpoint: <%= ENV['S3_ENDPOINT'] %>"; \
    echo "  secure: true"; \
    echo "  private: true"; \
    echo "  expires:"; \
    echo "  proxy: false"; \
    echo "  thumb_folder:"; \
} | tee /var/lib/redmine/config/s3.yml

{ \
    echo "<IfModule prefork.c>"; \
    echo "  StartServers        ${START_SERVERS}"; \
    echo "  MinSpareServers     ${MIN_SPARE_SERVERS}"; \
    echo "  MaxSpareServers     ${MAX_SPARE_SERVERS}"; \
    echo "  ServerLimit         ${SERVER_LIMIT}"; \
    echo "  MaxClients          ${MAX_CLIENTS}"; \
    echo "  MaxRequestsPerChild ${MAX_REQUESTS_PER_CHILD}"; \
    echo "</IfModule>"; \
    echo "PassengerMaxPoolSize ${PASSENGER_MAX_POOL_SIZE}"; \
    echo "PassengerMaxInstancesPerApp ${PASSENGER_MAX_INSTANCES_PER_APP}"; \
    echo "PassengerPoolIdleTime ${PASSENGER_POOL_IDLE_TIME}"; \
    echo "PassengerMaxRequests ${PASSENGER_MAX_REQUESTS}"; \
    echo "PassengerMinInstances ${PASSENGER_MIN_INSTANCES}"; \
    echo "PassengerMaxRequestQueueSize ${PASSENGER_MAX_REQUEST_QUEUESIZE}"; \
    echo "PassengerHighPerformance on"; \
    echo "RailsSpawnMethod smart"; \
    echo "PassengerFriendlyErrorPages off"; \
} | tee /etc/apache2/sites-enabled/default-parameter.conf;

# echo 'config.logger = Logger.new("log/#{ENV[\'RAILS_DB_USERNAME\']}/production.log")' > config/additional_environment.rb
echo 'config.logger = Logger.new("log/#{ENV['\'RAILS_DB\']}/production.log'")' > config/additional_environment.rb
mkdir -p $APP_HOME/log/$RAILS_DB

ruby /entrypoint.rb

if [ ! $RAILS_ENV = 'test' ]; then

{ \
    echo "default:"; \
    echo "  email_delivery:"; \
    echo "    delivery_method: <%= ENV['REDMINE_MAIL_DELIVERY_METHOD'].to_sym %>"; \
    echo "    smtp_settings:"; \
    echo "      address: <%= ENV['REDMINE_MAIL_ADDRESS'] %>"; \
    echo "      port: <%= ENV['REDMINE_MAIL_PORT'] %>"; \
    echo "      domain: <%= ENV['REDMINE_MAIL_DOMAIN'] %>"; \
    echo "  rmagick_font_path: <%= ENV['REDMINE_IMAGEMGICK_PATH'] %>"; \
} | tee /var/lib/redmine/config/configuration.yml

else
  rm -rf /var/lib/redmine/config/configuration.yml
fi

bundle exec rake generate_secret_token

bundle install
if [ $DB_CREATE = 'true' ]; then
  bundle exec rake db:create
fi
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate

if [ $RAILS_ENV = 'production' ]; then
  bundle exec rake redmine:load_default_data
else
  bundle exec rails db:fixtures:load
fi

chown redmine:redmine "$APP_HOME"
chmod 1777 "$APP_HOME"
chmod -R ugo=rwX config db
find log tmp -type d -exec chmod 1777 '{}' +
chmod 1777 log/*/*.log

exec "$@"
