require 'redis-namespace'

$config ||= {}
$config[:bot] ||= { source_url: 'https://github.com/anirbanmu/substitute-bot' }
$config[:reddit] ||= {}

$config[:reddit][:user_agent] ||= 'Substitute-Bot'
$config[:reddit][:client_id] ||= ENV['REDDIT_CLIENT_ID']
$config[:reddit][:client_secret] ||= ENV['REDDIT_CLIENT_SECRET']
$config[:reddit][:bot_username] ||= ENV['REDDIT_BOT_USERNAME'].downcase
$config[:reddit][:bot_password] ||= ENV['REDDIT_BOT_PASSWORD']

$redis_raw ||= Redis.new
$redis ||= Redis::Namespace.new('substitute-bot'.to_sym, :redis => $redis_raw)

def bot_config
  $config[:bot]
end

def reddit_config
  $config[:reddit]
end

def reddit_session_params
  { user_agent: reddit_config[:user_agent],
    client_id: reddit_config[:client_id],
    secret: reddit_config[:client_secret],
    username: reddit_config[:bot_username],
    password: reddit_config[:bot_password] }
end
