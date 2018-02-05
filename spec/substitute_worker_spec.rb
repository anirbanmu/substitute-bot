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
end
