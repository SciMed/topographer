require 'spec_helper'

describe Topographer::Importer::Mapper do
  describe '.build_mapper' do
    describe 'required mappings' do
      it 'can require a one to one field mapping' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.required_mapping 'Field1', 'field_1'
        end
        expect(mapper.required_mapping_columns).to include("Field1")
        expect(mapper.output_fields).to include('field_1')
      end
      it 'can require a many to one field mapping' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.required_mapping ['Field1', 'Field2'], 'field_1'
        end
        expect(mapper.required_mapping_columns).to include("Field1", "Field2")
        expect(mapper.output_fields).to include('field_1')
      end
      it 'cannot require a one to many field mapping' do
        expect { mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.required_mapping 'Field1', ['field_1', 'field_2']
        end
        }.to raise_error(Topographer::InvalidMappingError)
      end
    end
    describe 'optional mappings' do
      it 'can create an optional one to one field mapping' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.optional_mapping 'Field1', 'field_1'
        end
        expect(mapper.optional_mapping_columns).to include("Field1")
        expect(mapper.output_fields).to include('field_1')
      end
      it 'can create an optional many to one field mapping' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.optional_mapping ['Field1', 'Field2'], 'field_1'
        end
        expect(mapper.optional_mapping_columns).to include("Field1", "Field2")
        expect(mapper.output_fields).to include('field_1')
      end
      it 'cannot create an optional one to many field mapping' do
        expect { mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.optional_mapping 'Field1', ['field_1', 'field_2']
        end
        }.to raise_error(Topographer::InvalidMappingError)
      end
    end
    describe 'ignored mappings' do
      it 'can ignore a column' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.ignored_column 'Field1'
        end
        expect(mapper.ignored_mapping_columns).to include('Field1')
        expect(mapper.output_fields).to be_empty
      end

      it 'raises an error when adding a mapping whose output is already an output of another mapping' do
        expect { Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.optional_mapping 'Field1', 'field_1'
          m.required_mapping 'Field2', 'field_1'
        end }.to raise_error(Topographer::InvalidMappingError)
      end

      it 'raises an error when adding a ignored column, which is already an input of another mapping' do
        expect { Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.optional_mapping 'Field1', 'field_1'
          m.ignored_column 'Field1'
        end }.to raise_error(Topographer::InvalidMappingError)
      end

      it 'raises an error when adding a mapped column which has already been ignored' do
        expect { Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.ignored_column 'Field1'
          m.optional_mapping 'Field1', 'field_1'
        end }.to raise_error(Topographer::InvalidMappingError)
      end
    end

    describe 'validation mappings' do
      it 'can create a single column validation' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.validation_field 'Field 1 Validation', 'Field1' do |input|
            raise 'No Input' unless input
          end
        end
        expect(mapper.validation_mapping_columns).to include('Field1')
        expect(mapper.output_fields.empty?).to be_truthy
      end
      it 'can create a multicolumn validation' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.validation_field 'Multicolumn Validation', ['Field1', 'Field2'] do |input|
            raise 'No Input' unless input
          end
        end
        expect(mapper.validation_mapping_columns).to eql(['Field1', 'Field2'])
        expect(mapper.output_fields.empty?).to be_truthy
      end
      it 'raises an error if a validation name is repeated' do
        expect {
          mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
            m.validation_field 'Field 1 Validation', 'Field1' do |input|
              raise 'No Input' unless input
            end
            m.validation_field('Field 1 Validation', 'Field1') { |input| raise 'Test Error' }
          end
        }.to raise_error( Topographer::InvalidMappingError )
      end
    end

    describe 'static mappings' do
      it 'can create a static mapping' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.default_value 'Field1' do
            34
          end
        end
        expect(mapper.default_fields).to eql(['Field1'])
        expect(mapper.output_fields).to eql(['Field1'])
      end
      it 'cannot create a static mapping to many columns' do
        expect { mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.default_value ['Field1', 'Field2'] do
            34
          end
        end }.to raise_error(Topographer::InvalidMappingError)
      end
      it 'cannot add a static mapping to a field that has already been mapped' do
        expect { mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.required_mapping 'Field1', 'field1'
          m.default_value 'field1' do
            34
          end
        end }.to raise_error(Topographer::InvalidMappingError)
      end


    end

    describe 'key field mappings' do
      it 'should add a key field to the list of key fields' do
        mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
          m.key_field 'Field1'
        end
        expect(mapper.key_fields).to eql(['Field1'])
      end
      it 'should not allow multiple key fields at one time' do
        expect {
          mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
            m.key_field ['Field1', 'Field2']
          end
        }.to raise_error(Topographer::InvalidMappingError)
      end
      it 'should not allow the same key field more than once' do
        expect {
          mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
            m.key_field 'Field1'
            m.key_field 'Field1'
          end
        }.to raise_error(Topographer::InvalidMappingError)
      end
    end

    it 'associates the model class with the mapper instance' do
      mapper = Topographer::Importer::Mapper.build_mapper(Object) do |m|
        m.ignored_column 'Field1'
        m.optional_mapping 'Field2', 'field_1'
      end
      expect(mapper.model_class).to be Object
    end
  end

  describe '#input_structure_valid?' do
    let(:mapper) do
      Topographer::Importer::Mapper.build_mapper(Object) do |m|
        m.required_mapping 'Field1', 'field1'
        m.required_mapping 'Field2', 'field_4'
        m.optional_mapping 'Field3', 'field_6'
        m.validation_field('test validation', 'Field4') { |input| raise 'FAILURE' if !input }
        m.ignored_column 'Field5'
      end
    end

    let(:valid_input_structure_with_options) { ['Field1', 'Field2', 'Field3', 'Field4'] }
    let(:valid_input_structure_without_options) { ['Field1', 'Field2', 'Field4'] }
    let(:missing_required_column_structure) { ['Field1', 'Field3'] }
    let(:missing_validation_column_structure) { ['Field1', 'Field2', 'Field3'] }
    let(:bad_column_structure) { ['Field1', 'UnknownField', 'Field4'] }
    let(:unmapped_column_structure) {['Field1', 'Field2', 'Field3', 'Field4', 'UnmappedField'] }

    it 'returns false if required fields are missing' do
      expect(mapper.input_structure_valid?(missing_required_column_structure)).to be_falsey
    end
    it 'returns false if a validation field is missing' do
      expect(mapper.input_structure_valid?(missing_validation_column_structure)).to be_falsey
    end
    it 'returns true if all of the required fields are present' do
      expect(mapper.input_structure_valid?(valid_input_structure_without_options)).to be_truthy
    end
    it 'returns true if all the required and optional fields are present' do
      expect(mapper.input_structure_valid?(valid_input_structure_with_options)).to be_truthy
    end
    it 'returns true regardless of whether ignored fields are present' do
      expect(mapper.input_structure_valid?(valid_input_structure_with_options)).to be_truthy
      expect(mapper.input_structure_valid?(valid_input_structure_with_options+['Field5'])).to be_truthy
    end
    context 'not ignoring unmapped columns' do
      it 'returns false if there are any extra fields that have not been ignored' do
        expect(mapper.input_structure_valid?(bad_column_structure)).to be_falsey
      end
    end
    context 'ignoring unmapped columns' do
      it 'returns false if there are any extra fields that have not been ignored and required fields are missing' do
        expect(mapper.input_structure_valid?(bad_column_structure, ignore_unmapped_columns: true)).to be_falsey
      end
      it 'returns true if there are any extra fields that have not been ignored but all required fields are present' do
        expect(mapper.input_structure_valid?(unmapped_column_structure, ignore_unmapped_columns: true)).to be_truthy
      end
    end
  end

  describe '#bad_columns' do
    let(:mapper) do
      Topographer::Importer::Mapper.build_mapper(Object) do |m|
        m.required_mapping 'Field1', 'field1'
        m.required_mapping 'Field2', 'field_4'
        m.validation_field('test validation 2', 'Field2') { |input| raise 'FAILURE' if !input }
        m.optional_mapping 'Field3', 'field_6'
        m.validation_field('test validation', 'Field4') { |input| raise 'FAILURE' if !input }
        m.ignored_column 'Field5'
      end
    end
    let(:bad_column_structure) { ['Field1', 'Bad Field', 'Field3'] }

    it 'should return bad column names' do
      mapper.input_structure_valid?(bad_column_structure)
      expect(mapper.bad_columns).to eql(['Bad Field'])
    end
  end

  describe '#missing_columns' do
    let(:mapper) do
      Topographer::Importer::Mapper.build_mapper(Object) do |m|
        m.required_mapping 'Field1', 'field1'
        m.required_mapping 'Field2', 'field_4'
        m.optional_mapping 'Field3', 'field_6'
        m.validation_field('test validation', 'Field4') { |input| raise 'FAILURE' if !input }
        m.ignored_column 'Field5'
      end
    end
    let(:missing_column_structure) { ['Field1'] }

    it 'should return missing column names' do
      mapper.input_structure_valid?(missing_column_structure)
      expect(mapper.missing_columns).to eql(['Field2', 'Field4'])
    end
  end

  describe '#map_input' do
    let(:mapper) do
      Topographer::Importer::Mapper.build_mapper(Object) do |m|
        m.required_mapping 'Field1', 'field_1'
        m.required_mapping ['Field1', 'Field2'], 'field_2'
        m.validation_field('Field2 Validation', 'Field2') { |input| raise 'FAILURE' if input['Field2'] != 'datum2'}
        m.required_mapping('Field1', 'field_3') { |x| x['Field1'].length }
        m.required_mapping(['Field1', 'Field3'], 'field_4') { |x| x['Field1'].length * x['Field3'] }
        m.default_value('static_field') { 34 }
        m.optional_mapping('Field4', 'field_5')
      end
    end
    let(:valid_input) do
      double 'SourceData',
             source_identifier: 'row1',
             data: {'Field1' => 'datum1',
                    'Field2' => 'datum2',
                    'Field3' => 6},
             empty?: false
    end

    let(:invalid_data_input) do
      double 'SourceData',
             source_identifier: 'row1',
             data: {'Field1' => 'datum1',
                    'Field2' => 'bad_field2_data',
                    'Field3' => 6},
             empty?: false
    end

    let(:missing_field_input) do
      double 'SourceData',
             source_identifier: 'row1',
             data: {'Field1' => 'datum1',
                    'Field2' => 'datum2'},
             empty?: false
    end

    let(:empty_input) do
      double 'SourceData',
             source_identifier: 'row1',
             data: {},
             empty?: true
    end

    let(:result) do
      mapper.map_input(valid_input)
    end


    it 'maps one to one field information' do
      expect(result.data['field_1']).to eql('datum1')
    end

    it 'maps many to one field information' do
      expect(result.data['field_2']).to eql('datum1, datum2')
    end

    it 'maps one to one field information with complex behavior' do
      expect(result.data['field_3']).to eql(6)
    end

    it 'maps many to one field information with complex behavior' do
      expect(result.data['field_4']).to eql(36)
    end

    it 'maps static fields' do
      expect(result.data['static_field']).to eql(34)
    end

    it 'returns an error if required field is missing in input data' do
      invalid_field_result = mapper.map_input(missing_field_input)
      expect(invalid_field_result.errors?).to be_truthy
      expect(invalid_field_result.errors['field_4']).to include('Missing required input(s): `Field3` for `field_4`')
    end

    it 'returns an error if a validation does not pass' do
      invalid_data_result = mapper.map_input(invalid_data_input)
      expect(invalid_data_result.errors?).to be_truthy
      expect(invalid_data_result.errors['Field2 Validation']).to include('FAILURE')

    end

    it 'does not return an error if an optional field is missing in the input data' do
      expect(result.errors?).to be_falsey
    end

    it 'returns a `blank row` error if an entire row is blank' do
      empty_result = mapper.map_input(empty_input)
      expect(empty_result.errors?).to be_truthy
      expect(empty_result.errors['EmptyRow']).to include('empty row')
    end
  end
end
