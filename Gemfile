# frozen_string_literal: true

source "https://rubygems.org"

ruby '2.3.3', engine: 'jruby', engine_version: '9.1.15.0'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

#gem 'redd', git: 'https://github.com/avinashbot/redd.git'
gem 'redd', ">= 0.9.0.pre.3"
gem 'workers'

group :test do
  gem "rspec", "~> 3.7"
end
