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

if [ $RAILS_ENV -lt 'production' -o $RAILS_ENV -lt 'development' ]; then

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

exec "$@"