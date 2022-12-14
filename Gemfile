source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.2', '>= 6.1.2.1'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
# gem "sentry-ruby"
# gem "sentry-rails"
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'brakeman'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-callback-matchers'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # gem 'active_record_query_trace'
  gem "letter_opener"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'spree', '~> 4.2.0.rc5'
gem 'spree_auth_devise', '~> 4.3'
gem 'spree_gateway', '~> 3.9'
gem 'sassc', github: 'sass/sassc-ruby', branch: 'master'
# gem 'spree_shared', github: 'spree-contrib/spree_shared', branch: 'master'
gem 'acts_as_tenant'
gem 'spree_i18n', github: 'spree-contrib/spree_i18n', branch: 'master'
gem 'spree_paypal_express', github: 'spree-contrib/better_spree_paypal_express', branch: 'master'

# gem 'httparty'
# gem 'hashie'

gem 'savon', '~> 2.12.0'
gem 'sidekiq'
gem 'httparty'
gem 'hashie'
gem 'dotenv-rails', groups: [:development, :test]
gem 'dnsruby', '~> 1.59', '>= 1.59.3'
gem "aws-sdk-s3", require: false
gem 'aasm'
gem 'after_commit_everywhere', '~> 1.0'
gem 'whenever', require: false
# gem 'exception_notification'
gem 'typhoeus', '~> 1.4'
gem 'iso_country_codes'
gem 'activerecord-nulldb-adapter'

## DevOps Tools Start ##
gem 'elastic-apm', groups: [:qa, :staging, :production]
## DevOps Tools End ##

gem 'prawn'
gem 'prawn-table'


#gem 'deface', '~> 1.0', '>= 1.0.2'
gem 'rubocop', require: false


gem "roo", "~> 2.8.0"
gem 'roo-xls'
gem 'activejob-status'
