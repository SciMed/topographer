module Topographer
  class Importer
    class Mapper
      class IgnoredFieldMapping < Topographer::Importer::Mapper::FieldMapping
        def initialize(input_columns)
          @input_columns = input_columns
          @output_field = nil
        end

        def required?
          false
        end
      end
    end
  end
end

