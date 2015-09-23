require_relative 'helpers/write_log_to_csv'

module Topographer
  class Importer
    module Helpers

      def boolify(word)
        return nil if word.nil?

        case word.downcase
          when 'yes'
            true
          when 'no'
            false
          when 'true'
            true
          when 'false'
            false
        end
      end
    end
  end
end

