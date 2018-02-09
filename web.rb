require 'sinatra'
require 'trinidad'

require_relative 'globals'

configure do
  set :server, :trinidad
end

get '/' do
  haml :index, locals: { bingo: 'bango' }
end

get '/stylesheets/style.css' do
  scss :style
end
