# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.2'

gem 'erubis'
gem 'pg'
gem 'sinatra', '~>2.1.0'
gem 'sinatra-contrib'

group :development do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'rake'
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-rake'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end

group :production do
  gem 'puma'
end
