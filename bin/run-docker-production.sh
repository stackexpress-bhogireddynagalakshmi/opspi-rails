#!/bin/bash

set -x
set -e
set -o pipefail

bundle exec ./bin/rails db:migrate
bundle exec rails db:seed


bundle exec puma -C config/puma.rb





