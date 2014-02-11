require 'spec_helper'

describe Topographer::Importer::Logger::Simple do

  let(:logger) do
    Topographer::Importer::Logger::Simple.new
  end

  describe '#log_success' do
    it 'logs a success' do
      logger.log_success({record_id: 1,
                          message: 'success'})
      expect(logger.successful_imports).to eql 1
      expect(logger.failed_imports).to eql 0
    end
  end

  describe '#log_failure' do
    it 'logs a failure' do
      logger.log_failure({record_id: 1,
                          message: 'failure'})
      expect(logger.successful_imports).to eql 0
      expect(logger.failed_imports).to eql 1
    end
  end

  describe '#total_imports' do
    it 'returns the total number of imports' do
      logger.log_success({record_id: 1,
                          message: 'success'})
      logger.log_failure({record_id: 2,
                          message: 'failure'})
      expect(logger.total_imports).to eql 2
    end
  end

  describe '#errors?' do
    it 'returns true if there are fatal errors' do
      logger.log_fatal('input', 'FATAL ERROR')
      expect(logger.errors?).to be_true
    end
    it 'returns true if there are import errors' do
      logger.log_failure({record_id: 2,
                          message: 'failure'})
      expect(logger.errors?).to be_true
    end
    it 'returns false if there are no errors' do
      logger.log_success({record_id: 2,
                          message: 'failure'})
      expect(logger.errors?).to be_false
    end
  end
end
