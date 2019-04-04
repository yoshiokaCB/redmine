#!/bin/bash

bundle update
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate

if [ $RAILS_ENV = 'production' ]; then
  bundle exec rake redmine:load_default_data
else
  bundle exec rails db:fixtures:load
fi

rails s -b 0.0.0.0
