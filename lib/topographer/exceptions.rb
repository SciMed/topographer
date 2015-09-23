module Topographer
  class InvalidMappingError < StandardError; end
  class InvalidStructureError < Topographer::InvalidMappingError; end
  class MappingFailure < Topographer::InvalidMappingError; end
end

