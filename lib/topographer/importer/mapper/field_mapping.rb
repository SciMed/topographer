require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/blank'

module Topographer
  class Importer
    class Mapper
      class FieldMapping
        attr_reader :input_columns, :output_field

        def initialize(required, input_columns, output_field, &mapping_behavior)
          @required = required
          @input_columns = Array(input_columns)
          @output_field = output_field
          @mapping_behavior = mapping_behavior
          @invalid_keys = []
        end

        def process_input(input, result)
          mapping_input = input.slice(*input_columns)
          @invalid_keys = get_invalid_keys(mapping_input)
          data = (@invalid_keys.any?) ? nil : apply_mapping(mapping_input)
          if !data.nil?
            result.add_data(output_field, data)
          elsif required?
            result.add_error(output_field, invalid_input_error)
          end

        rescue => exception
          result.add_error(output_field, exception.message)

        end

        def required?
          @required
        end

        private

        def apply_mapping(mapping_input)
          if @mapping_behavior
            @mapping_behavior.(mapping_input)
          else
            (mapping_input.size > 1) ? mapping_input.values.join(', ') : mapping_input.values.first
          end
        end

        def invalid_input_error
          "Missing required input(s): `#{@invalid_keys.join(", ")}` for `#{@output_field}`"
        end

        def get_invalid_keys(input)
          missing_columns = @input_columns - input.keys
          #reject input that is not blank or the value `false`
          #this allows boolean inputs for required fields
          missing_data = @required ? input.reject { |k, v| !v.blank? || v == false }.keys : []
          missing_columns + missing_data
        end

      end
    end
  end
end
