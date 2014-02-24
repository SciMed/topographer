class Topographer::Importer::Mapper::ValidationFieldMapping < Topographer::Importer::Mapper::FieldMapping
  attr_reader :name

  def initialize(name, input_columns, &validation_block)
    unless block_given?
      raise Topographer::InvalidMappingError, 'Validation fields must have a behavior block'
    end
    @name = name
    @input_columns = Array(input_columns)
    @validation_block = validation_block
    @output_field = nil
  end

  def process_input(input, result)
    mapping_input = input.slice(*input_columns)
    @invalid_keys = get_invalid_keys(mapping_input)
    if @invalid_keys.blank?
      @validation_block.(mapping_input)
    else
      result.add_error(name, invalid_input_error)
    end

  rescue => exception
    result.add_error(name, exception.message)

  end

  def required?
    true
  end

  private
    def get_invalid_keys(input)
      @input_columns - input.keys
    end
end
