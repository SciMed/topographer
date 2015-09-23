require 'spec_helper'

describe Topographer::Importer::Mapper::DefaultFieldMapping do
  let(:static_mapping) do
    Topographer::Importer::Mapper::DefaultFieldMapping.new('field1') do
      10+5
    end
  end
  let(:failed_static_mapping) do
    Topographer::Importer::Mapper::DefaultFieldMapping.new('field1') do
      raise 'FAILURE'
    end
  end

  let(:result) { Topographer::Importer::Mapper::Result.new('test') }
  let(:result2) { Topographer::Importer::Mapper::Result.new('test') }
  describe '#initialize' do
    it 'should not create a static mapping without a behavior block' do
      expect { Topographer::Importer::Mapper::DefaultFieldMapping.new('broken mapping') }.
          to raise_error(Topographer::InvalidMappingError)
    end
  end
  describe '#process_input' do
    it 'should return the result of the behavior block' do
      static_mapping.process_input({}, result)
      expect(result.errors?).to be_falsey
      expect(result.data['field1']).to be 15
    end
    it 'should record any exceptions that occur within the block as errors' do
      failed_static_mapping.process_input({}, result)
      expect(result.errors?).to be_truthy
      expect(result.errors.values).to include('FAILURE')
    end
    it 'should not rescue Exceptions that do not inherit from standard error' do
      mapper = Topographer::Importer::Mapper::DefaultFieldMapping.new('output_column') do
        raise Exception, 'Field1 MUST BE 4'
      end
      expect{ mapper.process_input({'field1' => false}, result) }.to raise_error(Exception)
    end
  end
end
