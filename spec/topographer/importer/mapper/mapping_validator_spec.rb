require 'spec_helper'

class MockValidator
  include Topographer::Importer::Mapper::MappingValidator

  attr_reader :required_mappings, :optional_mappings, :ignored_mappings,
              :validation_mappings, :default_values, :key_fields,
              :output_fields, :input_columns, :ignored_mapping_columns

  def initialize
    @validation_mappings = {
      'Field1' => {},
      'Field2' => {}
    }
    @output_fields = %w(output_field1 output_field2)
    @input_columns = %w(input_column1 input_column2)
    @ignored_mapping_columns = %w(ignored_column1 ignored_column2)
    @key_fields = %w(key_field1)
  end

end

describe Topographer::Importer::Mapper::MappingValidator do

  let(:validator) do
    MockValidator.new
  end

  describe '#validate_unique_validation_name' do
    it 'should not raise an error if a name is not in the validation list' do
      expect {
        validator.validate_unique_validation_name('unique_field_name_37')
      }.not_to raise_error
    end
    it 'should raise an error if a name is in the validation list' do
      expect {
        validator.validate_unique_validation_name('Field1')
      }.to raise_error
    end
  end

  describe '#validate_unique_output_mapping' do
    it 'should not raise an error if a field is not already an output field' do
      expect {
        validator.validate_unique_output_mapping('unique_field_37')
      }.not_to raise_error
    end
    it 'should raise an error if a field is already an output field' do
      expect {
        validator.validate_unique_output_mapping('output_field2')
      }.to raise_error
    end
  end

  describe '#validate_unique_column_mapping_type' do
    it 'should not raise an error if a field is not already mapped' do
      expect {
        validator.validate_unique_column_mapping_type('input_column3')
      }.not_to raise_error
    end
    it 'should not raise an error if a field is already mapped but is not ignored' do
      expect {
        validator.validate_unique_column_mapping_type('input_column2')
      }.not_to raise_error
    end
    it 'should raise an error if a field is already ignored' do
      expect {
        validator.validate_unique_column_mapping_type('ignored_column1')
      }.to raise_error
    end
    it 'should raise an error when validating an ignored column that has already been mapped' do
      expect {
        validator.validate_unique_column_mapping_type('input_column1', ignored: true)
      }.to raise_error
      expect {
        validator.validate_unique_column_mapping_type('ignored_column1', ignored: true)
      }.to raise_error
    end
  end

  describe '#validate_unique_mapping' do
    it 'should not raise an error if a new mapping has a unique output field' do
      expect {
        validator.validate_unique_mapping('input_column2', 'output_field3')
      }.not_to raise_error
    end
    it 'should raise an error if a new mapping does not have a unique output field' do
      expect {
        validator.validate_unique_mapping('input_column2', 'output_field2')
      }.to raise_error
    end
    it 'should raise an error if a new mapping includes an already ignored column' do
      expect {
        validator.validate_unique_mapping('ignored_column2', 'output_field2')
      }.to raise_error
    end
  end
  it 'should raise an error if a new mapping includes many output fields' do
    expect {
      validator.validate_unique_mapping('ignored_column2', %w(output_field2 output_field3))
    }.to raise_error
  end

  describe '#validate_key_field' do
    it 'should raise an error if a new key field includes multiple fields' do
      expect {
        validator.validate_key_field(%w(output_field2 output_field3))
      }.to raise_error
    end
    it 'should raise an error if a key field is duplicated' do
      expect {
        validator.validate_key_field('key_field1')
      }.to raise_error
    end
    it 'should not raise an error if a key field is not already mapped' do
      expect {
        validator.validate_key_field('key_field2')
      }.not_to raise_error
    end
  end
end
