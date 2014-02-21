module Topographer::Importer::Mapper::MappingColumns
  def output_fields
    (required_mappings.merge(optional_mappings).merge(default_values)).values.map(&:output_field)
  end

  def required_input_columns
    (required_mapping_columns + validation_mapping_columns).uniq
  end

  def input_columns
    (required_mapping_columns + optional_mapping_columns + validation_mapping_columns).uniq
  end

  def default_fields
    default_values.keys
  end

  def validation_mapping_columns
    validation_mappings.values.flat_map(&:input_columns)
  end

  def ignored_mapping_columns
    ignored_mappings.values.flat_map(&:input_columns)
  end

  def optional_mapping_columns
    optional_mappings.values.flat_map(&:input_columns)
  end

  def required_mapping_columns
    required_mappings.values.flat_map(&:input_columns)
  end

  private
    def mapped_input_columns
      required_mapping_columns + optional_mapping_columns + ignored_mapping_columns + validation_mapping_columns
    end

    def mappings
      required_mappings.merge(optional_mappings).merge(ignored_mappings).merge(default_values)
    end

    def non_ignored_columns
      required_mappings.merge(optional_mappings)
    end
end
