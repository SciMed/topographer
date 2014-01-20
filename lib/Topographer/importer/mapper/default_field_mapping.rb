class Importer::Mapper::DefaultFieldMapping < Importer::Mapper::FieldMapping

  def initialize(output_column, &output_block)
    unless block_given?
      raise Topographer::InvalidMappingError, 'Static fields must have an output block'
    end
    @output_field = output_column
    @output_block = output_block
  end

  def process_input(_, result)
    @output_data = @output_block.()
    result.add_data(@output_field, @output_data)
  rescue => exception
    result.add_error(@output_field, exception.message)
  end

  def required?
    true
  end

end
