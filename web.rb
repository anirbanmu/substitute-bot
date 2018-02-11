require 'sinatra'
require 'trinidad'

require_relative 'globals'
require_relative 'reply_store'

configure do
  set :server, :trinidad
end

get '/' do
  haml :index, locals: { replies: ReplyStore::get_replies_with_details }
end

get '/stylesheets/style.css' do
  scss :style
end
