#!/bin/bash

bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:load_default_data
rails s -b 0.0.0.0