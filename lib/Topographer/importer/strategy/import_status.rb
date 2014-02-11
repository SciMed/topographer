class Topographer::Importer::Strategy::ImportStatus
  attr_reader :errors, :input_identifier, :timestamp
  attr_accessor :message

  def initialize(input_identifier)
    @input_identifier = input_identifier
    @errors = {mapping: [],
               validation: []}

  end

  def set_timestamp
    @timestamp ||= DateTime.now
  end

  def add_error(error_source, error)
    errors[error_source] << error
  end

  def error_count
    errors.values.flatten.length
  end

  def errors?
    errors.values.flatten.any?
  end

end
