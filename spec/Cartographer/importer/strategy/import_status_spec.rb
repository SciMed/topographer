require 'spec_helper'

describe Importer::Strategy::ImportStatus do
  let(:status) {Importer::Strategy::ImportStatus.new('row1')}
  describe '#add_error' do
    it 'should add errors' do
      status.add_error(:validation, 'ERROR')
      expect(status.error_count).to be 1
    end
  end
  describe '#set_timestamp' do
    it 'should set the timestamp the first time it is called' do
      expect(status.timestamp).to be_nil
      status.set_timestamp
      expect(status.timestamp).to be_a DateTime
    end
    it 'should not change the timestamp after it has been called' do
      status.set_timestamp
      timestamp = status.timestamp
      status.set_timestamp
      expect(timestamp).to eql(status.timestamp)
    end
  end
end
