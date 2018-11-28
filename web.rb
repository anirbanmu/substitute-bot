require 'sinatra'
require 'trinidad'
require 'bundler/setup'
require 'tilt/sassc'

require_relative 'globals'
require_relative 'reply_store'

configure do
  set :server, :trinidad
  set :show_exceptions, false
  set :raise_errors, false
end

get '/' do
  haml :index, locals: { replies: ReplyStore::get_replies_with_details }
end

get '/stylesheets/style.css' do
  scss :style
end

not_found do
  redirect to('/')
end
