source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'pg'
gem 'httparty'
gem 'nokogiri'
gem 'redis-rails'
gem 'devise'
gem 'sanitize'

# External storage
gem 'fog'
# gem 'rmagick', require: false (TODO: Replace with MiniMagick)
gem 'carrierwave'

# Background jobs
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', require: false
gem 'sidekiq-throttler'
gem 'sidekiq-status'

# Error tracking
gem 'sentry-raven', git: 'https://github.com/getsentry/raven-ruby.git'

# Frontend stuff
gem 'autoprefixer-rails'
gem 'compass-rails'
gem 'ceaser-easing'

# EmberJS
gem 'ember-rails'
gem 'ember-source', '1.8.0'
gem 'ember-data-source', '1.0.0.beta.11'

group :development, :test do
  
  # Environment variables
  gem 'dotenv-rails'
  
  # New rails web console
  gem 'web-console', '~> 2.0'
  
  # Byebug to stop execution anywhere and get a debugger console
  gem 'byebug'
  
  # Old gems we used for testing but might still be
  # used for our new BDD rspec tests.
  gem 'vcr'
  gem 'webmock'
  gem 'delorean'
  
  # Rspec gems
  gem 'rspec-rails'
  gem 'guard-rspec'
  
end