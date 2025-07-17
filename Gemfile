source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.2'

gem 'bigdecimal'
gem 'benchmark'
gem 'drb'

gem 'rack-timeout'

gem 'activeadmin'
gem 'devise'
gem 'cancancan'

gem 'isbn-calculator'
gem 'isbn_validation'
gem 'validate_url'

gem 'library_stdnums'
gem 'ean13'

gem 'country_select', '~>8.0.3'
gem 'iso-639'

gem 'mimemagic'

gem 'cocoon'

gem 'rack', '~>2.2.13'
gem 'rails', '~> 7.0.8.7'
gem 'nokogiri', '~>1.18.8'
gem 'rails-html-sanitizer', '~>1.4.4'

# Use Puma as the app server
gem 'puma', '~> 5.6.8'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# This replaces Webpacker in Rails 7.1
gem 'jsbundling-rails'

# Use Active Storage variant
gem 'image_processing', '~> 1.12'

gem 'pg', '~> 1.5.2'

gem 'htmlentities'

gem 'redcarpet'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'mysql2', '>= 0.5.3'
gem 'rubocop', '~> 1.69.2', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false
gem 'kaminari', '>=1.2.0'

gem 'open-uri'

gem 'browser'

gem "google-cloud-storage", "~> 1.11", require: false

gem 'thwait'

gem 'pg_search'

gem 'barnes'

gem 'jpg_or_webp', '~> 0.1.1'

gem 'shyguy', '~> 0.1.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'database_cleaner-active_record'

  gem 'rails-controller-testing'

  gem 'factory_bot_rails'
  gem 'faker'
  gem 'ffaker'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.4'

  # Rspec 6 RC1 is in use here. Must be updated on final replease of 6.0.
  gem 'rspec-rails', '>= 6.0.0.rc1'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.16.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "good_job", "~> 3.19"

gem "unicode-emoji", "~> 3.4"
