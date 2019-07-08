#!/bin/bash

{ \
    echo "production:"; \
    echo "  adapter: postgresql"; \
    echo "  database: <%= ENV['RAILS_DB'] %>_development"; \
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

ruby /entrypoint.rb
# COUNT=0
# $APP_HOME="/var/lib/redmine"
# while [ $COUNT -lt 100 ]; do

#     COUNT=$(( COUNT + 1 )) # COUNT をインクリメント
#     # echo "hgoehoge$COUNT"
#     # echo $COUNT

#     ln -s $APP_HOME "/var/lib/rm${COUNT}"

#     { \
#       echo "<VirtualHost *:80>"; \
#       echo "ServerName redmine-${COUNT}.dev.cloudz-0211.work"; \
#       echo "ServerAdmin webmaster@localhost"; \
#       echo "DocumentRoot /var/lib/rm${COUNT}/public"; \
#       echo "ErrorLog /error.log"; \
#       echo "CustomLog /access.log combined"; \
#       echo "RailsEnv ${RAILS_ENV}"; \
#       echo "PassengerEnabled on"; \
#       echo "SetEnv RAILS_DB rm${COUNT}"; \
#       echo "SetEnv S3_FOLDER_NAME rm${COUNT}-files"; \
#       echo "<Directory /var/lib/rm${COUNT}/public>"; \
#       echo "  Require all granted"; \
#       echo "</Directory>"; \
#       echo "</VirtualHost>"; \
#     } | tee "/etc/apache2/conf-available/rm${COUNT}.conf"

#     a2enconf "rm${COUNT}"

# done

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

chown redmine:redmine "$APP_HOME"
chmod 1777 "$APP_HOME"
chmod -R ugo=rwX config db
find log tmp -type d -exec chmod 1777 '{}' +

bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate

if [ $RAILS_ENV = 'production' ]; then
  bundle exec rake redmine:load_default_data
else
  bundle exec rails db:fixtures:load
fi

exec "$@"
