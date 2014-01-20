class Importer::Logger::LogEntry
  attr_reader :input_identifier,
              :model_name

  def initialize(input_identifier, model_name, import_status)
    @input_identifier = input_identifier
    @model_name = model_name
    @import_status = import_status
  end

  def source_identifier
    @import_status.input_identifier
  end

  def message
    @import_status.message
  end

  def timestamp
    @import_status.timestamp
  end

  def details
    @import_status.errors
  end

  def success?
    !failure?
  end

  def failure?
    @import_status.errors?
  end
end
