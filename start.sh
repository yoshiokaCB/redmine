#!/bin/bash

if [ $RAILS_ENV = 'production' ]; then
  bundle exec rake redmine:load_default_data
else
  bundle exec rails db:fixtures:load
fi

rails s -b 0.0.0.0
