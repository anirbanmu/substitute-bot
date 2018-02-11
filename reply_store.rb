require_relative 'globals'

module ReplyStore
  REPLIES_LIST_KEY = 'replies_posted'
  REPLY_DETAILS_PREPEND = 'replies:'

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

  # details is a Hash - created_at, body_html, requester, link_id
  def self.save_reply_details(id, details)
    return false if id.nil? || id == ''

    redis_result = $redis.multi do |r|
      r.mapped_hmset(reply_details_key(id), details)
      r.lpush(REPLIES_LIST_KEY, id)
    end

    # 20% chance of trimming list
    trim_replies if rand > 0.8

    redis_result[0] == 'OK' && 0 < redis_result[1]
  end

  def self.trim_replies(limit = 50)
    redis_result = $redis.multi do |r|
      r.lrange(REPLIES_LIST_KEY, limit, -1)
      r.ltrim(REPLIES_LIST_KEY, 0, limit - 1)
    end

    return if redis_result[0].empty?

    $redis.del(redis_result[0].map { |id| self.reply_details_key(id) } )
  end

  def self.reply_details_key(id)
    REPLY_DETAILS_PREPEND + id
  end
end
