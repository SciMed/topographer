module Topographer
  class Importer
    module Logger
      class Simple < Topographer::Importer::Logger::Base

        attr_reader :successes, :failures

        def initialize
          @successes = []
          @failures = []
          super
        end

        def log_success(message)
          @successes << message
        end

        def log_failure(message)
          @failures << message
        end

        def successful_imports
          @successes.size
        end

        def failed_imports
          @failures.size
        end

      end
    end
  end
end
