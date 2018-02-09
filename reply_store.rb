require_relative 'globals'

module ReplyStore
  REPLIES_LIST_KEY = 'replies_posted'

  def self.save_reply(id)
    return false if id.nil? || id == ''
    result = $redis.lpush(REPLIES_LIST_KEY, id)

    # 20% chance of trimming list
    $redis.ltrim(REPLIES_LIST_KEY, 0, 49) if rand > 0.8

    0 < result
  end

  def self.get_replies
    $redis.lrange(REPLIES_LIST_KEY, 0, 49)
  end
end
