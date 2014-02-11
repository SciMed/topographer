require 'spec_helper'
require 'ostruct'
require_relative 'mapped_model'

describe Topographer::Importer::Strategy::UpdateRecord do

  let(:strategy) { Topographer::Importer::Strategy::UpdateRecord.new(MappedModel.get_mapper) }
  let(:input) do
    double 'Data',
           source_identifier: 'record',
           data: {'Field1' => 'datum1',
                  'Field2' => 'datum2'}
  end
  let(:invalid_input) do
    double 'Data',
           source_identifier: 'bad record',
           data: {'Field1' => 'datum1'}
  end

  describe '#import_record' do
    it 'should return an ImportStatus object' do
      expect(strategy.import_record(input)).to be_a Topographer::Importer::Strategy::ImportStatus
    end
    it 'should import a record from valid input' do
      MappedModel.any_instance.should_receive(:save).once
      result = strategy.import_record(input)
      expect(result.errors?).to be false
    end
    it 'should not import a record from invalid input' do

      MappedModel.any_instance.should_not_receive(:save)
      import_status = strategy.import_record(invalid_input)
      expect(import_status.errors?).to be true
      expect(import_status.errors[:mapping]).to include('Missing required input(s): `Field2` for `field_2`')
      expect(import_status.errors[:validation]).to include('Field 2 is not datum2')
    end
    it 'should not save a record on a dry run' do
      MappedModel.any_instance.should_not_receive(:save)
      strategy.dry_run = true
      import_status = strategy.import_record(input)
      expect(import_status.errors?).to be false
    end
  end

end
