class Topographer::InvalidMappingError < StandardError; end
class Topographer::InvalidStructureError < Topographer::InvalidMappingError; end
class Topographer::MappingFailure < Topographer::InvalidMappingError; end

