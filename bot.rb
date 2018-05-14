require_relative 'globals'
require_relative 'comment_processor'

require 'redd'

class Heartbeat
  def initialize(beat_interval_in_seconds = 5 * 60)
    @last_beat = Time.now
    @interval = beat_interval_in_seconds
  end

  def beat
    now = Time.now
    if now - @last_beat > @interval
      @last_beat = now
      puts 'Heartbeat...'
    end
  end
end

def run(client = Redd.it(reddit_session_params))
  heartbeat = Heartbeat.new
  client.subreddit('all').comments.stream do |comment|
    CommentProcessor::perform_async(comment.name, comment.body)
    heartbeat.beat
  end
end

client = Redd.it(reddit_session_params)
begin
  run(client)
rescue => e
  puts "#{e.class}: #{e.to_s}"
  retry
end
