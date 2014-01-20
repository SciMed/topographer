require 'spec_helper'

describe Importer::Strategy::Base do
  let(:mapper) do
    double('Mapper')
  end
  let(:strategy) { Importer::Strategy::Base.new(mapper) }
  let(:status) do
    double 'Status',
           errors?: false
  end
  let(:bad_status) do
    double 'Status',
           errors?: true
  end
  describe '#initialize' do
    it 'creates a new Strategy instance with the given mapper' do
      strategy = Importer::Strategy::Base.new(mapper)
      strategy.instance_variable_get(:@mapper).should be(mapper)
    end
  end
  describe '#import_record' do
    it 'should raise NotImplementedError' do
      expect { strategy.import_record(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#should_persist_import?' do
    it 'returns true if the status has no errors and the import is not a dry run' do
      expect(strategy.should_persist_import?(status)).to be_true
    end
    it 'returns false if the status has errors regardless of whether the import is a dry run or not' do
      expect(strategy.should_persist_import?(bad_status)).to be_false
      strategy.dry_run = true
      expect(strategy.should_persist_import?(bad_status)).to be_false
    end
    it 'returns false if the status has no errors and the import is a dry run' do
      strategy.dry_run = true
      expect(strategy.should_persist_import?(status)).to be_false
    end
  end

end
