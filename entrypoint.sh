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
    echo "<VirtualHost *:80>"; \
    echo "ServerName ${SVN01}"; \
    echo "ServerAdmin webmaster@localhost"; \
    echo "DocumentRoot /var/lib/rm01/public"; \
    echo "ErrorLog /error.log"; \
    echo "CustomLog /access.log combined"; \
    echo "#RailsEnv production"; \
    echo "RailsEnv development"; \
    echo "PassengerEnabled on"; \
    echo "SetEnv RAILS_DB rm01"; \
    echo "SetEnv S3_FOLDER_NAME rm01-files"; \
    echo "<Directory /var/lib/rm01/public>"; \
    echo "  Require all granted"; \
    echo "</Directory>"; \
    echo "</VirtualHost>"; \
} | tee /etc/apache2/conf-available/rm01.conf
{ \
    echo "<VirtualHost *:80>"; \
    echo "ServerName ${SVN02}"; \
    echo "ServerAdmin webmaster@localhost"; \
    echo "DocumentRoot /var/lib/rm02/public"; \
    echo "ErrorLog /error.log"; \
    echo "CustomLog /access.log combined"; \
    echo "#RailsEnv production"; \
    echo "RailsEnv development"; \
    echo "PassengerEnabled on"; \
    echo "SetEnv RAILS_DB rm02"; \
    echo "SetEnv S3_FOLDER_NAME rm02-files"; \
    echo "<Directory /var/lib/rm02/public>"; \
    echo "  Require all granted"; \
    echo "</Directory>"; \
    echo "</VirtualHost>"; \
} | tee /etc/apache2/conf-available/rm02.conf
{ \
    echo "<VirtualHost *:80>"; \
    echo "ServerName ${SVN03}"; \
    echo "ServerAdmin webmaster@localhost"; \
    echo "DocumentRoot /var/lib/rm03/public"; \
    echo "ErrorLog /error.log"; \
    echo "CustomLog /access.log combined"; \
    echo "#RailsEnv production"; \
    echo "RailsEnv development"; \
    echo "PassengerEnabled on"; \
    echo "SetEnv RAILS_DB rm03"; \
    echo "SetEnv S3_FOLDER_NAME rm03-files"; \
    echo "<Directory /var/lib/rm03/public>"; \
    echo "  Require all granted"; \
    echo "</Directory>"; \
    echo "</VirtualHost>"; \
} | tee /etc/apache2/conf-available/rm03.conf

a2enconf rm01
a2enconf rm02
a2enconf rm03

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
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate

if [ $RAILS_ENV = 'production' ]; then
  bundle exec rake redmine:load_default_data
else
  bundle exec rails db:fixtures:load
fi

exec "$@"
