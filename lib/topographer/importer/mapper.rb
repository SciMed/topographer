require_relative 'mapper/mapping_validator'
require_relative 'mapper/mapping_columns'
require_relative 'mapper/mapper_builder'
require_relative 'mapper/field_mapping'
require_relative 'mapper/ignored_field_mapping'
require_relative 'mapper/validation_field_mapping'
require_relative 'mapper/default_field_mapping'
require_relative 'mapper/result'

module Topographer
  class Importer
    class Mapper

      include Topographer::Importer::Mapper::MappingColumns

      attr_reader :required_mappings, :optional_mappings, :ignored_mappings, :validation_mappings,
        :default_values, :key_fields, :bad_columns, :missing_columns, :model_class, :key_fields

      def self.build_mapper(model_class)
        mapper_builder = MapperBuilder.new()
        yield mapper_builder

        new(mapper_builder, model_class)
      end

      def initialize(mapper_builder, model_class)
        @required_mappings = mapper_builder.required_mappings
        @optional_mappings = mapper_builder.optional_mappings
        @ignored_mappings = mapper_builder.ignored_mappings
        @validation_mappings = mapper_builder.validation_mappings
        @default_values = mapper_builder.default_values
        @key_fields = mapper_builder.key_fields
        @field_mappings = mapper_builder.field_mappings
        @model_class = model_class
      end

      def input_structure_valid?(input_columns, options={})
        ignore_unmapped_columns = options.fetch(:ignore_unmapped_columns, false)
        @bad_columns ||= input_columns - mapped_input_columns
        @missing_columns ||= required_input_columns - input_columns

        if ignore_unmapped_columns
          @missing_columns.empty?
        else
          @bad_columns.empty? && @missing_columns.empty?
        end
      end

      def map_input(source_data)
        mapping_result = Result.new(source_data.source_identifier)

        if source_data.empty?
          handle_no_data(mapping_result)
        else
          @validation_mappings.values.each do |validation_field_mapping|
            validation_field_mapping.process_input(source_data.data, mapping_result)
          end

          output_fields.each do |output_field|
            field_mapping = mappings[output_field]
            field_mapping.process_input(source_data.data, mapping_result)
          end
        end

        mapping_result
      end

      private
      def handle_no_data(mapping_result)
        mapping_result.add_error('EmptyRow', 'Unable to import empty row.')
      end
    end
  end
end
