module Topographer::Importer::Mapper::MappingValidator

  def validate_unique_validation_name(name)
    raise Topographer::InvalidMappingError, "A validation already exists with the name `#{name}`" if validation_mappings.has_key?(name)
  end

  def validate_unique_output_mapping(output_field)
    if output_fields.include?(output_field)
      raise Topographer::InvalidMappingError, 'Output column already mapped.'
    end
  end

  def validate_unique_column_mapping_type(mapping_input_columns, options = {})
    ignored = options.fetch(:ignored, false)
    mapping_input_columns = Array(mapping_input_columns)
    mapping_input_columns.each do |col|
      if ignored && ((input_columns + ignored_mapping_columns).include?(col))
        raise Topographer::InvalidMappingError, 'Input column already mapped to an output column.'
      elsif (ignored_mapping_columns.include?(col))
        raise Topographer::InvalidMappingError, 'Input column already ignored.'
      end
    end
  end

  def validate_unique_mapping(mapping_input_columns, output_field)
    if (output_field.is_a?(Array))
      raise Topographer::InvalidMappingError, 'One to many mapping is not supported'
    end
    validate_unique_column_mapping_type(mapping_input_columns)
    validate_unique_output_mapping(output_field)
  end

  def validate_key_field(field)
    if field.is_a?(Array)
      raise Topographer::InvalidMappingError, 'One to many mapping is not supported'
    elsif key_fields.include?(field)
      raise Topographer::InvalidMappingError, "Field `#{field}` has already been included as a key"
    end
  end
end
