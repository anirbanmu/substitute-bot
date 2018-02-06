$config ||= {}
$config[:reddit] ||= {}

$config[:reddit][:user_agent] ||= 'Substitute-Bot'
$config[:reddit][:client_id] ||= ENV['REDDIT_CLIENT_ID']
$config[:reddit][:client_secret] ||= ENV['REDDIT_CLIENT_SECRET']
$config[:reddit][:bot_username] ||= ENV['REDDIT_BOT_USERNAME']
$config[:reddit][:bot_password] ||= ENV['REDDIT_BOT_PASSWORD']

def reddit_config
  $config[:reddit]
end
