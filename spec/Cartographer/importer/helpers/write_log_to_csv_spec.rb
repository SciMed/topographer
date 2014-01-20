require 'spec_helper'

describe Importer::Helpers::WriteLogToCSV do
  let(:successful_entry) do
    status = Importer::Strategy::ImportStatus.new('test-input')
    status.set_timestamp
    Importer::Logger::LogEntry.new('test-input', 'TestModel', status)
  end
  let(:failed_entry) do
    status = Importer::Strategy::ImportStatus.new('test-input')
    status.set_timestamp
    (1+rand(6)).times do |n|
      status.add_error(:mapping, "Test error #{n}")
    end
    Importer::Logger::LogEntry.new('test-input', 'TestModel', status)
  end
  let(:fatal_error) do
    Importer::Logger::FatalErrorEntry.new('test-input', 'FATAL ERROR')
  end
  let(:successes) do
    successes = []
    2.times do
      successes << successful_entry
    end
    successes
  end
  let(:failures) do
    failures = []
    3.times do
      failures << failed_entry
    end
    failures
  end
  let(:fatal_errors) do
    errors = []
    4.times do
      errors << fatal_error
    end
    errors
  end
  let(:logger) do
    double 'Logger::Base',
      successful_imports: 2,
      failed_imports: 3,
      total_imports: 5,
      fatal_error?: false,
      errors?: true,
      successes: successes,
      failures: failures,
      fatal_errors: fatal_errors,
      entries?: true,
      all_entries: (successes + failures + fatal_errors)
  end

  describe '#write_log_to_csv' do
    it 'should write a passed logger instance to a CSV file' do
      file = double('file')
      CSV.should_receive(:open).with('fake_file_path', 'wb').and_yield(file)
      file.should_receive(:<<).exactly(12).times
      Importer::Helpers::WriteLogToCSV.instance.write_log_to_csv(logger, 'fake_file_path', write_all: true)
    end
    it 'should only write failures and fatal errors if write_all is false' do
      file = double('file')
      CSV.should_receive(:open).with('fake_file_path', 'wb').and_yield(file)
      file.should_receive(:<<).exactly(10).times
      Importer::Helpers::WriteLogToCSV.instance.write_log_to_csv(logger, 'fake_file_path', write_all: false)
    end
  end
end
