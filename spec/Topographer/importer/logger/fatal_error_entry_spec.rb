require 'spec_helper'

describe Topographer::Importer::Logger::FatalErrorEntry do
  let(:entry) { Topographer::Importer::Logger::FatalErrorEntry.new('test-input', 'failure message') }
  describe '#failure?' do
    it 'should return true' do
      expect(entry.failure?).to be_true
    end
  end
  describe '#success?' do
    it 'should return false' do
      expect(entry.success?).to be_false
    end
  end
  describe '#source_identifier' do
    it 'should return `import failure`' do
      expect(entry.source_identifier).to eql 'import failure'
    end
  end
  describe '#timestamp' do
    it 'should have a timestamp' do
      expect(entry.timestamp).to be_a(DateTime)
    end
  end
  describe '#message' do
    it 'should return the message it was initialized with' do
      expect(entry.message).to eql('failure message')
    end
  end
end

