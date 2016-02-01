module Topographer
  class Importer
    module Logger
      # A log entry from an import. Each row imported produces an entry, regardless of status.
      #
      # @!attribute input_identifier [r]
      #   @return [String] the identifier of the input (e.g. the name of the spreadsheet being imported)
      # @!attribute model_name [r]
      #   @return [String] the name of the model class being imported for the log entry
      class LogEntry
        attr_reader :input_identifier,
          :model_name

        def initialize(input_identifier, model_name, import_status)
          @input_identifier = input_identifier
          @model_name = model_name
          @import_status = import_status
        end

        # @return [String] the identifier of the input row the entry is for
        def source_identifier
          @import_status.input_identifier
        end

        # @return [String] the message associated with the log entry
        def message
          @import_status.message
        end

        # @return [DateTime] the time that the logged event occurred
        def timestamp
          @import_status.timestamp
        end

        # @return [Hash] a hash of the error details that occurred during the import
        def details
          @import_status.errors
        end

        # @return [Boolean] true if there are no errors
        def success?
          !failure?
        end

        # @return [Boolean] true if there are errors
        def failure?
          @import_status.errors?
        end
      end
    end
  end
end
