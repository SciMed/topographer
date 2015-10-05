module Topographer
  class Importer
    module Input
      class DelimitedSpreadsheet < Topographer::Importer::Input::Base
        include Enumerable

        # Creates a new DelimitedSpreadsheet input wrapper.  NOTE: Since Topographer relies on headers
        # to map from input to output columns, you should enable header parsing in the CSV object passed in
        #
        # @param name [String] the name of the delimited file being dealt with (e.g. My Data File 1)
        # @param spreadsheet [CSV] the spreadsheet object to be parsed
        def initialize(name, spreadsheet)
          @sheet = spreadsheet
          @name = name
        end

        # Returns the headers in the CSV file, or if header parsing is not enabled, an empty array
        #
        # @return [Array<String>] the headers in the file
        def get_header
          unless @header
            if @sheet.headers === true
              @sheet.shift
            elsif @sheet.headers.nil?
              @header = []
            end
            @header ||= @sheet.headers
          end

          @header
        end

        def input_identifier
          @name
        end

        def each
          @sheet.each_with_index do |data, index|
            row_number = index + 2
            source_identifier = "Row: #{row_number}"


              yield Topographer::Importer::Input::SourceData.new(
                source_identifier,
                data.to_h
              )
          end
        end
      end
    end
  end
end
