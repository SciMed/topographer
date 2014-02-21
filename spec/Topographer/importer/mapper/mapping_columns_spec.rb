require 'spec_helper'
require 'ostruct'

class MockMapping
  include Topographer::Importer::Mapper::MappingColumns

  attr_reader :required_mappings, :optional_mappings, :ignored_mappings,
              :validation_mappings, :default_values, :key_fields


  def initialize
    @required_mappings = {
      'field1' => OpenStruct.new(output_field: 'field1',
                                 input_columns: ['column1', 'column2']
      ),
      'field2' => OpenStruct.new(output_field: 'field2',
                                 input_columns: ['column3']
      )
    }
    @optional_mappings = {
      'field3' => OpenStruct.new(output_field: 'field3',
        input_columns: ['column4', 'column5']
      ),
      'field4' => OpenStruct.new(output_field: 'field4',
        input_columns: ['column8']
      )
    }
    @default_values = {
      'field5' => OpenStruct.new(output_field: 'field5')
    }
    @validation_mappings = {
      'validation1' => OpenStruct.new(input_columns: ['column1', 'column2']),
      'validation2' => OpenStruct.new(input_columns: 'column6')
    }
    @ignored_mappings = {
      'column4' => OpenStruct.new(input_columns: 'column4'),
      'column5' => OpenStruct.new(input_columns: 'column5')
    }
  end
end

describe Topographer::Importer::Mapper::MappingColumns do

  let(:mapping) { MockMapping.new }

  describe '#output_fields' do
    it 'should return an array of all fields that are required, optional, or have default values' do
      expect(mapping.output_fields).to eql(['field1', 'field2', 'field3', 'field4', 'field5'])
    end
  end
  describe '#required_mapping_columns' do
    it 'returns an array of the required input column names' do
      expect(mapping.required_mapping_columns).to eql(['column1', 'column2', 'column3'])
    end
  end
  describe '#optional_mapping_columns' do
    it 'returns an array of the optional input column names' do
      expect(mapping.optional_mapping_columns).to eql(['column4', 'column5', 'column8'])
    end
  end
  describe '#ignored_mapping_columns' do
    it 'returns an array of the ignored input column names' do
      expect(mapping.ignored_mapping_columns).to eql(['column4', 'column5'])
    end
  end
  describe '#validation_mapping_columns' do
    it 'returns an array of the validation mapping input columns' do
      expect(mapping.validation_mapping_columns).to eql(['column1', 'column2', 'column6'])
    end
  end
  describe '#required_input_columns' do
    it 'should return an array of the required and validation columns' do
      expect(mapping.required_input_columns).to eql(['column1', 'column2', 'column3', 'column6'])
    end
  end
  describe '#input_columns' do
    it 'should return an array of the required, validation, and optional columns' do
      expect(mapping.input_columns).to eql(['column1', 'column2', 'column3', 'column4', 'column5', 'column8', 'column6'])
    end
  end
  describe '#default_fields' do
    it 'should return all the fields given a default value' do
      expect(mapping.default_fields).to eql(['field5'])
    end
  end

end
