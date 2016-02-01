module Topographer
  class Importer
    class Mapper
      class MapperBuilder
        include Topographer::Importer::Mapper::MappingColumns
        include Topographer::Importer::Mapper::MappingValidator

        attr_reader :required_mappings, :optional_mappings, :ignored_mappings,
          :validation_mappings, :default_values, :key_fields, :field_mappings

        def initialize
          @required_mappings = {}
          @optional_mappings = {}
          @ignored_mappings = {}
          @validation_mappings = {}
          @default_values = {}
          @key_fields = []
          @field_mappings = {}
        end

        def required_mapping(input_columns, output_field, &mapping_behavior)
          validate_unique_mapping(input_columns, output_field)
          mapping = Topographer::Importer::Mapper::FieldMapping.new(true, input_columns, output_field, &mapping_behavior)
          @required_mappings[output_field] = mapping
          @field_mappings[output_field] = mapping
        end

        def optional_mapping(input_columns, output_field, &mapping_behavior)
          validate_unique_mapping(input_columns, output_field)
          mapping = Topographer::Importer::Mapper::FieldMapping.new(false, input_columns, output_field, &mapping_behavior)
          @optional_mappings[output_field] = mapping
          @field_mappings[output_field] = mapping
        end

        def validation_field(name, input_columns, &mapping_behavior)
          validate_unique_validation_name(name)
          mapping = Topographer::Importer::Mapper::ValidationFieldMapping.new(name, input_columns, &mapping_behavior)
          @validation_mappings[name] = mapping
          @field_mappings[name] = mapping
        end

        def default_value(output_field, &mapping_behavior)
          validate_unique_mapping([], output_field)
          mapping = Topographer::Importer::Mapper::DefaultFieldMapping.new(output_field, &mapping_behavior)
          @default_values[output_field] = mapping
          @field_mappings[output_field] = mapping
        end

        def key_field(output_field)
          validate_key_field(output_field)
          @key_fields << output_field
        end

        def ignored_column(input_column)
          validate_unique_column_mapping_type(input_column, ignored: true)
          @ignored_mappings[input_column] = Topographer::Importer::Mapper::IgnoredFieldMapping.new(input_column)
        end
      end
    end
  end
end
