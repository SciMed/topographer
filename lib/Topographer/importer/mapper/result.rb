class Importer::Mapper::Result
  attr_reader :data, :errors, :source_identifier

  def initialize(source_identifier)
    @source_identifier = source_identifier
    @data = {}
    @errors = {}
  end

  def add_data (key, value)
    @data[key] = value
  end

  def add_error (key, value)
    @errors[key] = value
  end

  def errors?
    errors.any?
  end
end
