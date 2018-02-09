# frozen_string_literal: true

source "https://rubygems.org"

ruby '2.3.3', engine: 'jruby', engine_version: '9.1.15.0'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "redd", ">= 0.9.0.pre.3"
gem "sucker_punch", "~> 2.0"
gem "redis-namespace", "~> 1.6"
gem "sinatra", "~> 2.0"
gem "trinidad", "~> 1.4"
gem "haml", "~> 5.0"
gem "sass", "~> 3.5"

group :test do
  gem "rspec", "~> 3.7"
  gem "simplecov", "~> 0.15.1"
end
