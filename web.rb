require 'sinatra'
require 'trinidad'

configure do
  set :server, :trinidad
end

get '/' do
  haml :index, locals: { bingo: 'bango' }
end
