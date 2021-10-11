set -x
set -e
set -o pipefail

bundle exec ./bin/rails db:drop

bundle exec ./bin/rails db:setup
