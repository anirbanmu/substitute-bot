require 'sinatra'
require 'trinidad'
require 'redd'

require_relative 'globals'
require_relative 'reply_store'

configure do
  set :server, :trinidad
end

get '/' do
  haml :index, locals: { replies: Redd.it(reddit_session_params).from_ids(ReplyStore::get_replies) }
end

get '/stylesheets/style.css' do
  scss :style
end
