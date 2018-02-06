require_relative 'config'
require_relative 'substitute_worker'

require 'redd'
require 'workers'

def run
  session = Redd.it(reddit_session_params)

  worker_pool = Workers::Pool.new(worker_class: SubstituteWorker,
                                  on_exception: proc { |e| puts "A worker encountered an exception: #{e.class}: #{e.message}" } )

  session.subreddit('all').comments.stream do |comment|
    worker_pool.enqueue(:new_comment, { id: comment.name, body: comment.body })
  end

  worker_pool.dispose(5)
end

run
