require 'spec_helper'

describe Topographer::Importer::Logger::Base do
  let(:logger){Topographer::Importer::Logger::Base.new}
  describe '#log_fatal' do
    it 'should log a fatal error' do
      logger.log_fatal('test input', 'Fatal Error')
      expect(logger.fatal_errors.first).to be_a Topographer::Importer::Logger::LogEntry
      expect(logger.fatal_errors.first)
    end
  end
end
