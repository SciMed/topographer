class Topographer::Importer::Input::Roo < Topographer::Importer::Input::Base
  include Enumerable

  def initialize(roo_sheet, header_row=1, data_row=2)
    @sheet = roo_sheet
    @header = @sheet.row(header_row).map(&:strip)
    @start_data_row = data_row
    @end_data_row = @sheet.last_row
  end

  def get_header
    @header
  end

  def input_identifier
    #This is apparently how you get the name of the sheet...this makes me sad
    @sheet.default_sheet
  end

  def each
    @start_data_row.upto @end_data_row do |row_number|
      data = @sheet.row(row_number)
      source_identifier = "Row: #{row_number}"

      if data.reject{ |column| column.blank? }.any?
        yield Topographer::Importer::Input::SourceData.new(
          source_identifier,
          Hash[@header.zip(data)]
        )
      end
    end
  end
end
