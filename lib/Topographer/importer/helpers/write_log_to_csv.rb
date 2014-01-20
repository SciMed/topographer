require 'singleton'
require 'csv'
class Importer::Helpers::WriteLogToCSV
  include Singleton

  def initialize

  end

  def write_log_to_csv(log, output_file_path, options = {})
    @log = log
    @write_all = options.fetch(:write_all, true)
    CSV.open(output_file_path, 'wb') do |csv_file|
      csv_file << get_detail_header
      csv_file << get_details
      csv_file << get_log_header if @log.entries?
      @log.all_entries.each do |entry|
        if entry.failure? || @write_all

          csv_file << format_log_entry(entry)
        end
      end
    end
  end

  private

    def get_detail_header
      if @write_all
        ['Fatal Errors', 'Total Imports', 'Successful Imports', 'Failed Imports']
      else
        ['Fatal Errors', 'Failed Imports']
      end
    end

    def get_details
      details = []
      details << ((@log.fatal_error?) ? @log.fatal_errors.size : 'None')
      if @write_all
        details << @log.total_imports
        details << @log.successful_imports
      end
      details << @log.failed_imports
    end

    def get_log_header
      header = []
      header << 'Input Identifier'
      header << 'Source Identifier'
      header << 'Model Class'
      header << 'Timestamp'
      header << 'Status'
      header << 'Message'
      header << 'Details'
    end

    def format_log_entry(log_entry)
      entry = []
      entry << log_entry.input_identifier
      entry << log_entry.source_identifier
      entry << log_entry.model_name
      entry << log_entry.timestamp.strftime('%F - %T:%L')
      entry << ((log_entry.success?) ? 'Success' : 'Failure')
      entry << log_entry.message
      entry << format_log_entry_details(log_entry.details)
    end

    def format_log_entry_details(details)
      if details
        formatted_details = []
        details.keys.each do |key|
          detail_string = ''
          detail_messages = Array(details[key])
          if detail_messages.any?
            detail_string << key.to_s.capitalize << ': '
            detail_string << detail_messages.join(', ')
          end
          formatted_details << detail_string unless detail_string.empty?
        end
        formatted_details.join("; ")
      else
        ''
      end
    end
end
