class Topographer::Importer::Input::SourceData
  attr_reader :source_identifier, :data

  def initialize(source_identifier, data)
    @source_identifier = source_identifier
    @data = data
  end

  def empty?
    @data.empty?
  end
end