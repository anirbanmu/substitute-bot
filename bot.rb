require_relative 'globals'
require_relative 'substitute_worker'

require 'redd'

def run
  Redd.it(reddit_session_params).subreddit('all').comments.stream do |comment|
    SubstituteWorker::perform_async(comment.name, comment.body)
  end
end

run
