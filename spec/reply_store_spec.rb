require_relative '../reply_store'

RSpec.describe ReplyStore do
  before(:each) { $redis_raw.flushdb }
  after(:each) { $redis_raw.flushdb }

  describe '.save_reply' do
    it 'does not change list on nil id' do
      expect(ReplyStore::save_reply(nil)).to be false
      expect($redis_raw.dbsize).to be 0
    end

    it 'does not change list on blank id' do
      expect(ReplyStore::save_reply('')).to be false
      expect($redis_raw.dbsize).to be 0
    end

    it 'adds entry to list of replies' do
      expect(ReplyStore::save_reply('MY_ID')).to eq(true)
      expect($redis.lrange(ReplyStore::REPLIES_LIST_KEY, 0, -1)).to eq(['MY_ID'])
    end
  end

  describe '.get_replies' do
    it 'returns empty list when nothing has been saved' do
      expect(ReplyStore::get_replies).to be_empty
    end

    it 'returns 50 most recent replies' do
      replies = (1..100).map(&:to_s)
      $redis.rpush(ReplyStore::REPLIES_LIST_KEY, replies)
      expect(ReplyStore::get_replies).to eq(replies[0..49])
    end
  end

  describe '.save_reply_details' do
    let (:id) { 'MY_ID' }
    let (:dummy_details) { { 'dummy' => 'dummy_value' } }
    it 'does not change list on nil id' do
      expect(ReplyStore::save_reply_details(nil, dummy_details)).to be false
      expect($redis_raw.dbsize).to be 0
    end

    it 'does not change list on blank id' do
      expect(ReplyStore::save_reply_details('', dummy_details)).to be false
      expect($redis_raw.dbsize).to be 0
    end

    it 'saves details & adds to replies list' do
      expect(ReplyStore::save_reply_details(id, dummy_details)).to be true
      expect($redis.lrange(ReplyStore::REPLIES_LIST_KEY, 0, -1)).to eq([id])
      expect($redis.hgetall(ReplyStore::reply_details_key(id))).to eq(dummy_details)
    end
  end

  describe '.trim_replies' do
    let (:dummy_details) { { 'dummy' => 'dummy_value' } }

    it 'does nothing if number is lower than specified' do
      replies = (1..40).map(&:to_s)
      $redis.rpush(ReplyStore::REPLIES_LIST_KEY, replies)
      replies.each{ |id| $redis.mapped_hmset(ReplyStore::reply_details_key(id), dummy_details) }

      ReplyStore::trim_replies(40)

      expect($redis.lrange(ReplyStore::REPLIES_LIST_KEY, 0, -1)).to eq(replies)
      replies.each{ |id| expect($redis.hgetall(ReplyStore::reply_details_key(id))).to eq(dummy_details) }
    end

    it 'trims list to specified number & deletes details of trimmed ids' do
      replies = (1..100).map(&:to_s)
      $redis.rpush(ReplyStore::REPLIES_LIST_KEY, replies)
      replies.each{ |id| $redis.mapped_hmset(ReplyStore::reply_details_key(id), dummy_details) }

      ReplyStore::trim_replies(60)

      expect($redis.lrange(ReplyStore::REPLIES_LIST_KEY, 0, -1)).to eq(replies[0..59])
      replies[0..59].each{ |id| expect($redis.hgetall(ReplyStore::reply_details_key(id))).to eq(dummy_details) }
      replies[60..-1].each{ |id| expect($redis.hgetall(ReplyStore::reply_details_key(id))).to be_empty }
    end
  end

  describe '.get_replies_with_details' do
    let (:dummy_details) { { 'dummy' => 'dummy_value' } }

    it 'returns nothing if list is empty' do
      expect(ReplyStore::get_replies_with_details).to be_empty
    end

    it 'returns nothing if list is non-empty but there are no details' do
      replies = (1..100).map(&:to_s)
      $redis.rpush(ReplyStore::REPLIES_LIST_KEY, replies)
      expect(ReplyStore::get_replies_with_details).to be_empty
    end

    it 'returns specified number of detail hashes' do
      replies = (1..100).map(&:to_s)
      $redis.rpush(ReplyStore::REPLIES_LIST_KEY, replies)
      replies.each{ |id| $redis.mapped_hmset(ReplyStore::reply_details_key(id), dummy_details) }

      expect(ReplyStore::get_replies_with_details(60)).to eq((1..60).map{ |id| dummy_details })
    end
  end
end
