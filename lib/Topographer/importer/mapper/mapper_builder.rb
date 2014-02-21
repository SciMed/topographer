class Topographer::Importer::Mapper::MapperBuilder
  include Topographer::Importer::Mapper::MappingColumns
  include Topographer::Importer::Mapper::MappingValidator

  attr_reader :required_mappings, :optional_mappings, :ignored_mappings,
              :validation_mappings, :default_values, :key_fields

  def initialize
    @required_mappings = {}
    @optional_mappings = {}
    @ignored_mappings = {}
    @validation_mappings = {}
    @default_values = {}
    @key_fields = []
  end

  def required_mapping(input_columns, output_field, &mapping_behavior)
    validate_unique_mapping(input_columns, output_field)
    @required_mappings[output_field] = Topographer::Importer::Mapper::FieldMapping.new(true, input_columns, output_field, &mapping_behavior)
  end

  def optional_mapping(input_columns, output_field, &mapping_behavior)
    validate_unique_mapping(input_columns, output_field)
    @optional_mappings[output_field] = Topographer::Importer::Mapper::FieldMapping.new(false, input_columns, output_field, &mapping_behavior)
  end

  def validation_field(name, input_columns, &mapping_behavior)
    validate_unique_validation_name(name)
    @validation_mappings[name] = Topographer::Importer::Mapper::ValidationFieldMapping.new(name, input_columns, &mapping_behavior)
  end

  def default_value(output_field, &mapping_behavior)
    validate_unique_mapping([], output_field)
    @default_values[output_field] = Topographer::Importer::Mapper::DefaultFieldMapping.new(output_field, &mapping_behavior)
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
