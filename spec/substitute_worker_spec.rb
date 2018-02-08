require_relative '../substitute_worker'

RSpec.describe SubstituteWorker do
  describe '.scan_for_substitute_command' do
    it 'returns nil for nil text' do
      expect(SubstituteWorker::scan_for_substitute_command(nil)).to be_nil
    end

    it 'returns nil for empty text' do
      expect(SubstituteWorker::scan_for_substitute_command('')).to be_nil
    end

    it 'returns nil if format is incorrect' do
      expect(SubstituteWorker::scan_for_substitute_command('s\4\3')).to be_nil
    end

    it 'returns search & replacement for simple command' do
      expect(SubstituteWorker::scan_for_substitute_command('s/m/r')).to eq(['m', 'r'])
    end

    it 'allows # instead of /' do
      expect(SubstituteWorker::scan_for_substitute_command('s#m#r')).to eq(['m', 'r'])
    end

    it 'returns nil if command is not first line in string' do
      expect(SubstituteWorker::scan_for_substitute_command("\ns#m#r")).to eq(nil)
    end

    it 'returns nil if command is not first thing in string' do
      expect(SubstituteWorker::scan_for_substitute_command(" s#m#r")).to eq(nil)
    end

    it 'allows space in search & replace terms' do
      expect(SubstituteWorker::scan_for_substitute_command('s/sp ace/s pace')).to eq(['sp ace', 's pace'])
    end

    it 'disregards newlines after command' do
      expect(SubstituteWorker::scan_for_substitute_command("s/sp ace/s pace\nshould not be there")).to eq(['sp ace', 's pace'])
    end
  end

  describe '.substitute' do
    it 'returns nil if nothing is changed' do
      expect(SubstituteWorker::substitute('text', 'ex', 'ex')).to be_nil
    end

    it 'can handle spaces in match & replacement' do
      expect(SubstituteWorker::substitute('text beep', 'ext bee', 't e')).to eq('tt ep')
    end

    it 'treats match as regex' do
      expect(SubstituteWorker::substitute('text', '\w+', 'blah')).to eq('blah')
    end

    it 'does not perform any processing on match string' do
      expect(SubstituteWorker::substitute('2', '#{1+1}', '3')).to be_nil
    end

    it 'can use capture groups in replacement' do
      expect(SubstituteWorker::substitute('23', '(\d)', '<\1>')).to eq('<2><3>')
    end
  end

  describe '.reschedule_after_ratelimit' do
    let(:comment_id) { 'COMMENT ID' }
    let(:comment_body) { 'COMMENT BODY'}

    it 'schedules job in correct amount of seconds' do
      time = 5
      expect(SubstituteWorker).to receive(:perform_in).with(time + 5, comment_id, comment_body)
      SubstituteWorker::reschedule_after_ratelimit(comment_id, comment_body, "try again in #{time} seconds.")
    end

    it 'schedules job in correct amount of minutes' do
      time = 5
      expect(SubstituteWorker).to receive(:perform_in).with(time * 60 + 5, comment_id, comment_body)
      SubstituteWorker::reschedule_after_ratelimit(comment_id, comment_body, "try again in #{time} minutes.")
    end

    it 'schedules job in correct amount of hours' do
      time = 5
      expect(SubstituteWorker).to receive(:perform_in).with(time * 60 * 60 + 5, comment_id, comment_body)
      SubstituteWorker::reschedule_after_ratelimit(comment_id, comment_body, "try again in #{time} hours.")
    end
  end

  describe '.get_parent_comment' do
    let(:comment) { double(parent: double) }

    it 'returns nil when parent says it is not a comment' do
      expect(comment.parent).to receive(:is_a?).with(Redd::Models::Comment).and_return(false)
      expect(SubstituteWorker::get_parent_comment(comment)).to be_nil
    end

    it 'returns parent when parent says it is a comment' do
      expect(comment.parent).to receive(:is_a?).with(Redd::Models::Comment).and_return(true)
      expect(SubstituteWorker::get_parent_comment(comment)).to eq(comment.parent)
    end
  end

  describe '.should_respond' do
    let(:bot_name) { 'bot' }
    let(:not_bot_name) { 'not-bot' }

    it 'returns true when no authors are self' do
      expect(SubstituteWorker::should_respond(bot_name, not_bot_name, not_bot_name)).to be true
    end

    it 'returns false when comment author is self' do
      expect(SubstituteWorker::should_respond(bot_name, bot_name, not_bot_name)).to be false
    end

    it 'returns false when parent author is self' do
      expect(SubstituteWorker::should_respond(bot_name, not_bot_name, bot_name)).to be false
    end

    it 'returns false when both authors are self' do
      expect(SubstituteWorker::should_respond(bot_name, bot_name, bot_name)).to be false
    end
  end
end
