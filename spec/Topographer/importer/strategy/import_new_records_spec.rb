require 'spec_helper'
require 'ostruct'
require_relative 'mapped_model'

describe Topographer::Importer::Strategy::ImportNewRecord do
  let(:valid_status) do
    double 'Result',
           source_identifier: 'row1',
           data: {'field_1' => 'datum1', 'field_2' => 'datum2'},
           errors?: false,
           errors: {}
  end
  let(:invalid_result) do
    double 'Result',
           source_identifier: 'row1',
           data: {'field_1' => 'dataum1'},
           errors?: true,
           errors: {'field_2' => 'Missing input(s): `Field2` for `field_2`'}

  end
  let(:mapper) do
    double('Mapper', map_input: valid_status, model_class: MappedModel)
  end

  let(:strategy) { Topographer::Importer::Strategy::ImportNewRecord.new(MappedModel.get_mapper) }
  let(:input) do
    double 'Data',
           source_identifier: 'record',
           data: {'Field1' => 'datum1',
                  'Field2' => 'datum2'}
  end

  describe '#initialize' do
    it 'creates a new Strategy instance with the given mapper' do
      strategy = Topographer::Importer::Strategy::ImportNewRecord.new(mapper)
      strategy.instance_variable_get(:@mapper).should be(mapper)
    end
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
      mapper.stub(:map_input).and_return(invalid_result)
      strategy = Topographer::Importer::Strategy::ImportNewRecord.new(mapper)
      MappedModel.any_instance.should_not_receive(:save)
      import_status = strategy.import_record(input)
      expect(import_status.errors?).to be true
      expect(import_status.errors[:mapping]).to include('Missing input(s): `Field2` for `field_2`')
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
