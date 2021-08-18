#!/bin/bash

set -x
set -e
set -o pipefail

bundle exec ./bin/rails db:migrate
#bundle exec rails db:seed

crontab /etc/cron.d/hello-cron
/etc/cron.d/hello-cron start
#/etc/init.d/cron start
RAILS_ENV=production whenever --update-crontab

#bundle exec sidekiq -d -C config/sidekiq.yml

bundle exec puma -C config/puma.rb





