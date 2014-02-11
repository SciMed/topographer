class Topographer::Importer::Mapper
  require_relative 'mapper/field_mapping'
  require_relative 'mapper/ignored_field_mapping'
  require_relative 'mapper/validation_field_mapping'
  require_relative 'mapper/default_field_mapping'
  require_relative 'mapper/result'

  attr_reader :bad_columns, :missing_columns, :model_class, :key_fields

  def self.build_mapper(model_class)
    mapper = self.new(model_class)
    yield mapper

    mapper
  end

  def initialize(model_class)
    @required_mappings = {}
    @optional_mappings = {}
    @ignored_mappings = {}
    @validation_mappings = {}
    @default_values = {}
    @key_fields = []
    @model_class = model_class
  end

  def required_columns
    @required_mappings.values.flat_map(&:input_columns)
  end

  def optional_columns
    @optional_mappings.values.flat_map(&:input_columns)
  end

  def ignored_columns
    @ignored_mappings.values.flat_map(&:input_columns)
  end

  def validation_columns
    @validation_mappings.values.flat_map(&:input_columns)
  end

  def default_fields
    @default_values.keys
  end

  def input_columns
    required_columns + optional_columns + validation_columns
  end

  def required_input_columns
    required_columns + validation_columns
  end

  def output_fields
    (@required_mappings.merge(@optional_mappings).merge(@default_values)).values.map(&:output_field)
  end

  def required_mapping(input_columns, output_field, &mapping_behavior)
    validate_unique_mapping(input_columns, output_field)
    @required_mappings[output_field] = FieldMapping.new(true, input_columns, output_field, &mapping_behavior)
  end

  def optional_mapping(input_columns, output_field, &mapping_behavior)
    validate_unique_mapping(input_columns, output_field)
    @optional_mappings[output_field] = FieldMapping.new(false, input_columns, output_field, &mapping_behavior)
  end

  def validation_field(name, input_columns, &mapping_behavior)
    validate_unique_validation_name(name)
    @validation_mappings[name] = ValidationFieldMapping.new(name, input_columns, &mapping_behavior)
  end

  def default_value(output_field, &mapping_behavior)
    validate_unique_mapping([], output_field)
    @default_values[output_field] = DefaultFieldMapping.new(output_field, &mapping_behavior)
  end

  def key_field(output_field)
    validate_key_field(output_field)
    @key_fields << output_field
  end

  def ignored_column(input_column)
    validate_unique_column_mapping_type(input_column, ignored: true)
    @ignored_mappings[input_column] = IgnoredFieldMapping.new(input_column)
  end

  def input_structure_valid?(input_columns)
    @bad_columns ||= input_columns - mapped_input_columns
    @missing_columns ||= required_input_columns - input_columns
    @bad_columns.empty? && @missing_columns.empty?
  end

  def map_input(source_data)
    mapping_result = Result.new(source_data.source_identifier)

    @validation_mappings.values.each do |validation_field_mapping|
      validation_field_mapping.process_input(source_data.data, mapping_result)
    end

    output_fields.each do |output_field|
      field_mapping = mappings[output_field]
      field_mapping.process_input(source_data.data, mapping_result)
    end

    mapping_result
  end

  private
    def mapped_input_columns
      required_columns + optional_columns + ignored_columns + validation_columns
    end

    def mappings
      @required_mappings.merge(@optional_mappings).merge(@ignored_mappings).merge(@default_values)
    end

    def non_ignored_columns
      @required_mappings.merge(@optional_mappings)
    end

    def validate_key_field(field)
      if field.is_a?(Array)
        raise Topographer::InvalidMappingError, 'One to many mapping is not supported'
      elsif @key_fields.include?(field)
        raise Topographer::InvalidMappingError, "Field `#{field}` has already been included as a key"
      end
    end

    def validate_unique_mapping(input_columns, output_field)
      if(output_field.is_a?(Array))
        raise Topographer::InvalidMappingError, 'One to many mapping is not supported'
      end
      validate_unique_column_mapping_type(input_columns)
      validate_unique_output_mapping(output_field)
    end

    def validate_unique_column_mapping_type(mapping_input_columns, options = {})
      ignored = options.fetch(:ignored, false)
      mapping_input_columns = Array(mapping_input_columns)
      mapping_input_columns.each do |col|
        if ignored && ((input_columns + ignored_columns).include?(col))
          raise Topographer::InvalidMappingError, 'Input column already mapped to an output column.'
        elsif(ignored_columns.include?(col))
          raise Topographer::InvalidMappingError, 'Input column already ignored.'
        end
      end
    end

    def validate_unique_output_mapping(output_field)
      if output_fields.include?(output_field)
        raise Topographer::InvalidMappingError, 'Output column already mapped.'
      end
    end

    def validate_unique_validation_name(name)
      raise Topographer::InvalidMappingError, "A validation already exists with the name `#{name}`" if @validation_mappings.has_key?(name)
    end

end
