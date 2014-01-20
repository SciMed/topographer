class Importer::Logger::FatalErrorEntry < Importer::Logger::LogEntry
  attr_reader :message, :timestamp, :model_name

  def initialize(input_identifier, message)
    @timestamp = DateTime.now
    @input_identifier = input_identifier
    @model_name = 'N/A'
    @message = message
  end
  def source_identifier
    'import failure'
  end
  def details
    {}
  end
  def failure?
    true
  end
end
