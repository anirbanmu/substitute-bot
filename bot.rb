require_relative 'globals'
require_relative 'comment_processor'

require 'redd'

def run
  Redd.it(reddit_session_params).subreddit('all').comments.stream do |comment|
    CommentProcessor::perform_async(comment.name, comment.body)
  end
end

run
