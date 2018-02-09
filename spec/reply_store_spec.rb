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
end
