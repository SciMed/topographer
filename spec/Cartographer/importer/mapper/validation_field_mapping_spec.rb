require 'spec_helper'

describe Topographer::Importer::Mapper::ValidationFieldMapping do
  let(:validation_mapping) do
    Topographer::Importer::Mapper::ValidationFieldMapping.new('test mapping', ['field1', 'field2', 'field3']) do |input|
      sum = input.values.flatten.inject(0) {|sum, x| sum+x}
      raise 'Sum must be 15' if sum != 15
    end
  end
  let(:valid_input) do
    {'field1' => 4, 'field2' => 5, 'field3' => 6}
  end
  let(:invalid_input) do
    {'field1' => 3, 'field2' => 4, 'field3' => 5}
  end
  let(:result) { Topographer::Importer::Mapper::Result.new('test') }
  describe '#initialize' do
    it 'should not create a validation mapping without a behavior block' do
      expect { Topographer::Importer::Mapper::ValidationFieldMapping.new('test mapping', ['field1', 'field2', 'field3']) }.
        to raise_error(Topographer::InvalidMappingError)
    end
  end
  describe '#process_input' do
    it 'should not return an error if the validation block passes' do
      validation_mapping.process_input(valid_input, result)
      expect(result.errors?).to be_false
      expect(result.data.blank?).to be_true
    end
    it 'should return an error if the validation block raises an error' do
      validation_mapping.process_input(invalid_input, result)
      expect(result.errors?).to be_true
      expect(result.errors.values).to include('Sum must be 15')
    end
    it 'should not rescue Exceptions that do not inherit from standard error' do
      mapper = Topographer::Importer::Mapper::ValidationFieldMapping.new('test mapping', ['field1', 'field2', 'field3']) do |input|
        sum = input.values.flatten.inject(0) {|sum, x| sum+x}
        raise Exception, 'Sum must be 15' if sum != 15
      end
      expect{ mapper.process_input(invalid_input, result) }.to raise_error(Exception)
    end
  end
end
