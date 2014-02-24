require 'spec_helper'

describe Topographer::Importer::Mapper::MapperBuilder do

  let(:builder) { Topographer::Importer::Mapper::MapperBuilder.new }

  describe '#required_mapping' do
    it 'should add a new simple required mapping' do
      builder.required_mapping('input_column1', 'output_field1')
      expect(builder.required_mappings.count).to eql(1)
      expect(builder.required_mappings['output_field1']).to be_an_instance_of(Topographer::Importer::Mapper::FieldMapping)
    end
    it 'should add a new complex required mapping' do
      builder.required_mapping 'input_column1', 'output_field1' do |inputs|
        'foo'
      end
      expect(builder.required_mappings.count).to eql(1)
      expect(builder.required_mappings['output_field1']).to be_an_instance_of(Topographer::Importer::Mapper::FieldMapping)
    end
    it 'should raise an error if the output field has already been mapped' do
      builder.required_mapping('input_column1', 'output_field1')
      expect{
        builder.required_mapping('input_column2', 'output_field1')
      }.to raise_error
    end
  end

  describe '#optional_mapping' do
    it 'should add a new simple optional mapping' do
      builder.optional_mapping('input_column1', 'output_field1')
      expect(builder.optional_mappings.count).to eql(1)
      expect(builder.optional_mappings['output_field1']).to be_an_instance_of(Topographer::Importer::Mapper::FieldMapping)
    end
    it 'should add a new complex optional mapping' do
      builder.optional_mapping 'input_column1', 'output_field1' do |inputs|
        'foo'
      end
      expect(builder.optional_mappings.count).to eql(1)
      expect(builder.optional_mappings['output_field1']).to be_an_instance_of(Topographer::Importer::Mapper::FieldMapping)
    end
    it 'should raise an error if the output field has already been mapped' do
      builder.optional_mapping('input_column1', 'output_field1')
      expect{
        builder.optional_mapping('input_column2', 'output_field1')
      }.to raise_error
    end
  end

  describe '#validation_field' do
    it 'should add a new validation field mapping' do
      builder.validation_field('validation_1', 'input_column1') do
        return true
      end
      expect(builder.validation_mappings.count).to eql(1)
      expect(builder.validation_mappings['validation_1']).to be_an_instance_of(Topographer::Importer::Mapper::ValidationFieldMapping)
    end
    it 'should raise an error if there is no behavior block provided' do
      expect {
        builder.validation_field('validation_1', 'input_column1')
      }.to raise_error
    end
    it 'should raise an error if a validation mapping already exists with a given name' do
      builder.validation_field('validation_1', 'input_column1') do
        return true
      end
      expect {
        builder.validation_field('validation_1', 'input_column1') do
          return true
        end
      }.to raise_error
    end
  end

  describe '#default_value' do
    it 'should add a new default value mapping' do
      builder.default_value('output_field1') do
        return true
      end
      expect(builder.default_values.count).to eql(1)
      expect(builder.default_values['output_field1']).to be_an_instance_of(Topographer::Importer::Mapper::DefaultFieldMapping)
    end
    it 'should raise an error if there is no behavior block provided' do
      expect {
        builder.default_value('output_field1')
      }.to raise_error
    end
    it 'should raise an error if a default value mapping already exists for a column' do
      builder.default_value('output_field1') do
        return true
      end
      expect {
        builder.default_value('output_field1') do
          return true
        end
      }.to raise_error
    end
  end

  describe '#key_field' do
    it 'should add a new key field mapping' do
      builder.key_field('output_field1')
      expect(builder.key_fields.count).to eql(1)
      expect(builder.key_fields.first).to eql('output_field1')
    end
    it 'should raise an error if a default value mapping already exists for a column' do
      builder.key_field('output_field1')
      expect {

        builder.key_field('output_field1')
      }.to raise_error
    end
  end

  describe '#ignored_column' do
    it 'should add a new ignored column' do
      builder.ignored_column('column1')
      expect(builder.ignored_mappings.count).to eql(1)
      expect(builder.ignored_mappings['column1']).to be_an_instance_of(Topographer::Importer::Mapper::IgnoredFieldMapping)
    end
    it 'should raise an error if the column has already been ignored or added as an input' do
      builder.ignored_column('column1')
      builder.required_mapping('column2', 'field1')
      expect {
        builder.ignored_column('column1')
      }.to raise_error
      expect {
        builder.ignored_column('column2')
      }.to raise_error
    end
  end
end
