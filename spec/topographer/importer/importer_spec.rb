require 'spec_helper'
require 'ostruct'

class MockImportable < OpenStruct
  include Topographer::Importer::Importable

  def self.create(params)
    self.new(params)
  end

  def valid?
    self.errors = OpenStruct.new(full_messages: [])
    if field_2 == 'datum2'
      true
    else
      self.errors = OpenStruct.new(full_messages: ['Field 2 is not datum2'])
      false
    end
  end

  def self.get_mapper(strategy_class)
    case
    when  strategy_class == HashImportStrategy
      Topographer::Importer::Mapper.build_mapper(MockImportable) do |mapping|
        mapping.required_mapping 'Field1', 'field_1'
        mapping.required_mapping 'Field2', 'field_2'
        mapping.optional_mapping 'Field3', 'field_3'
        mapping.ignored_column 'IgnoredField'
      end
    end
  end
end

class HashImportStrategy < Topographer::Importer::Strategy::Base
  attr_reader :imported_data

  def initialize(mapper)
    @imported_data = []
    @mapper = mapper
  end

  def import_record(source_data)
    mapping_result = mapper.map_input(source_data)
    new_model = mapper.model_class.new(mapping_result.data)
    new_model.valid?
    model_errors = new_model.errors.full_messages
    status = get_import_status(mapping_result, model_errors)

    @imported_data << new_model unless status.errors?

    status
  end

end

class MockInput
  include Enumerable

  def initialize

  end
  def get_header
    ['Field1',
     'Field2',
     'Field3']
  end

  def input_identifier
    'test'
  end

  def importable?
    true
  end

  def each
    yield Topographer::Importer::Input::SourceData.new('1', {'Field1' => 'datum1', 'Field2' => 'datum2'})
    yield Topographer::Importer::Input::SourceData.new('2', {'Field1' => 'datum2', 'Field2' => 'datum2', 'Field3' => 'datum3'})
    yield Topographer::Importer::Input::SourceData.new('3', {'Field1' => 'datum3', 'Field2' => 'invalid value!!!!1ONE'})  #I am INVALID!!!
    yield Topographer::Importer::Input::SourceData.new('4', {'Field1' => 'datum4', 'Field2' => 'datum2', 'Field3' => 'datum3', 'IgnoredField' => 'ignore me'})
  end
end

describe Topographer::Importer do
  let(:input) { MockInput.new }
  let(:model_class) { MockImportable }
  let(:strategy_class) { HashImportStrategy }
  let(:bad_header_input) do
    double 'Input',
           get_header: ['BadCol1', 'BadCol2', 'Field1', 'Field3'],
           input_identifier: 'Test',
           importable?: true
  end
  let(:simple_logger) { Topographer::Importer::Logger::Simple.new }
  let(:import_log) { Topographer::Importer.import_data(input, model_class, strategy_class, simple_logger) }

  describe '.import_data' do
    it 'returns a logger instance' do
      expect(import_log).to be simple_logger
    end

    it 'tries to import data from a valid import object' do
      expect(import_log.total_imports).to be 4
    end

    it 'imports valid data and does not import invalid data' do
      expect(import_log.successful_imports).to be 3
    end

    it 'logs invalid data' do
      expect(import_log.errors?).to be_true
      expect(import_log.failed_imports).to be 1
    end

    it 'does not import data with an invalid header' do
      import_log = Topographer::Importer.import_data(bad_header_input, model_class, strategy_class, simple_logger)
      expect(import_log.errors?).to be_true
      expect(import_log.fatal_error?).to be_true
      expect(import_log.fatal_errors.first.message).
        to match(/Invalid Input Header.+Missing Columns:\s+Field2.+Invalid Columns:\s+BadCol1.+BadCol2/)
    end

    it 'does import data with umapped columns when ignoring unmapped columns' do
      extra_column_input = input
      extra_column_input.stub(:get_header) { %w(Field1 Field2 Field3 UnknownField1) }

      import_log = Topographer::Importer.import_data(extra_column_input, model_class, strategy_class, simple_logger, ignore_unmapped_columns: true)

      expect(import_log.fatal_error?).to be_false
      expect(import_log.total_imports).to be 4
      expect(import_log.successful_imports).to be 3
    end
  end
  describe '.build_mapper' do
    it 'returns a mapper with the defined mappings' do
      mapper = Topographer::Importer.build_mapper(MockImportable) do |mapping|
          mapping.required_mapping 'Field1', 'field_1'
          mapping.required_mapping 'Field2', 'field_2'
          mapping.optional_mapping 'Field3', 'field_3'
          mapping.ignored_column 'IgnoredField'
      end
      expect(mapper.required_mapping_columns).to eql(['Field1', 'Field2'])
      expect(mapper.optional_mapping_columns).to eql(['Field3'])
      expect(mapper.ignored_mapping_columns).to eql(['IgnoredField'])
    end
  end
end
