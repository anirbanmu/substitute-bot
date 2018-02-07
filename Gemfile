# frozen_string_literal: true

source "https://rubygems.org"

ruby '2.3.3', engine: 'jruby', engine_version: '9.1.15.0'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'redd', ">= 0.9.0.pre.3"
gem "sucker_punch", "~> 2.0"

group :test do
  gem "rspec", "~> 3.7"
end
