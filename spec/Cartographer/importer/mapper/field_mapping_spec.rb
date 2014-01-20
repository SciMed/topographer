require 'spec_helper'

describe Importer::Mapper::FieldMapping do
  let(:required_simple_mapping) { Importer::Mapper::FieldMapping.new(true, ['field1'], 'output_column') }
  let(:required_simple_mapping_with_validation) do
    Importer::Mapper::FieldMapping.new(true, ['field1'], 'output_column') do |input|
      if input['field1'] != 4
        raise 'Field1 MUST BE 4'
      end
    end
  end
  let(:required_complex_mapping) do
    Importer::Mapper::FieldMapping.new(true, ['field1', 'field2', 'field3'], 'output_column') do |input|
      if input['field1'] != 4
        raise 'Field1 MUST BE 4'
      end
      input.values.flatten.inject(0) {|sum, x| sum+x}
    end
  end
  let(:optional_simple_mapping) { Importer::Mapper::FieldMapping.new(false, 'field1', 'output_column') }
  let(:optional_complex_mapping) do
    Importer::Mapper::FieldMapping.new(false, ['field1', 'field2', 'field3'], 'output_column') do |input|
      if input['field1'] != 4
        raise 'Field1 MUST BE 4'
      end
      input.values.flatten.inject(0) {|sum, x| sum+x}
    end
  end
  let(:valid_input) do
    {'field1' => 4, 'field2' => 5, 'field3' => 6}
  end
  let(:invalid_complex_input) do
    {'field1' => 3, 'field2' => 4, 'field3' => 5}
  end
  let(:result) { Importer::Mapper::Result.new('test') }
  describe '#process_input' do
    context 'required mappings' do
      it 'maps required simple mappings when input is valid' do
        required_simple_mapping.process_input(valid_input, result)
        expect(result.errors?).to be_false
        expect(result.data['output_column']).to eql(4)
      end
      it 'maps required complex mappings when input is valid' do
        required_complex_mapping.process_input(valid_input, result)
        expect(result.errors?).to be_false
        expect(result.data['output_column']).to eql(15)
      end
      it 'returns an error for required simple mappings when the input key is missing' do
        required_simple_mapping.process_input({}, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Missing required input(s): `field1` for `output_column`')
        expect(result.data.empty?).to be_true
      end
      it 'returns an error for required simple mappings when the input data is blank' do
        required_simple_mapping.process_input({'field1' => nil}, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Missing required input(s): `field1` for `output_column`')
        expect(result.data['output_column']).to be_nil
      end
      it 'returns an error for required simple mappings when the mapping block raises an exception' do
        required_simple_mapping_with_validation.process_input({'field1' => 3}, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Field1 MUST BE 4')
        expect(result.data.empty?).to be_true
      end
      it 'returns an error for required complex mappings when the input key is missing' do
        required_complex_mapping.process_input({'field1' => 4}, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Missing required input(s): `field2, field3` for `output_column`')
        expect(result.data.empty?).to be_true
      end
      it 'returns an error for required complex mappings when the mapping block raises an exception' do
        required_complex_mapping.process_input(invalid_complex_input, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Field1 MUST BE 4')
        expect(result.data.empty?).to be_true
      end
    end
    context 'optional mappings' do
      it 'maps optional simple mappings when input is valid' do
        optional_simple_mapping.process_input(valid_input, result)
        expect(result.errors?).to be_false
        expect(result.data['output_column']).to eql(4)
      end
      it 'maps optional complex mappings when input is valid' do
        optional_complex_mapping.process_input(valid_input, result)
        expect(result.errors?).to be_false
        expect(result.data['output_column']).to eql(15)
      end
      it 'does not return an error for optional simple mappings when the input key is missing' do
        optional_simple_mapping.process_input({}, result)
        expect(result.errors?).to be_false
        expect(result.data.empty?).to be_true
      end
      it 'does not return an error for optional simple mappings when the input data is blank' do
        optional_simple_mapping.process_input({'field1' => nil}, result)
        expect(result.errors?).to be_false
        expect(result.data['output_column']).to be_nil
      end
      it 'does not return an error for optional complex mappings when an input key is missing' do
        optional_complex_mapping.process_input({'field1' => 4}, result)
        expect(result.errors?).to be_false
        expect(result.data.empty?).to be_true
      end
      it 'returns an error for optional complex mappings when the mapping block raises an exception' do
        optional_complex_mapping.process_input(invalid_complex_input, result)
        expect(result.errors?).to be_true
        expect(result.errors.values).to include('Field1 MUST BE 4')
        expect(result.data.empty?).to be_true
      end
    end
    it 'maps data when the result of the mapping is a false value' do
      #required_simple_mapping.stub(:apply_mapping).and_return(false)
      required_simple_mapping.process_input({'field1' => false}, result)
      expect(result.errors?).to be_false
      expect(result.data['output_column']).to eql(false)
    end
    it 'should not rescue Exceptions that do not inherit from standard error' do
      mapper = Importer::Mapper::FieldMapping.new(true, 'field1', 'output_column') do |input|
        raise Exception, 'Field1 MUST BE 4'
      end
      expect{ mapper.process_input({'field1' => false}, result) }.to raise_error(Exception)
    end

  end
end
