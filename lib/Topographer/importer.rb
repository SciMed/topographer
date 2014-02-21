class Topographer::Importer
  require_relative 'importer/mapper'
  require_relative 'importer/strategy'
  require_relative 'importer/importable'
  require_relative 'importer/logger'
  require_relative 'importer/input'
  require_relative 'importer/helpers'

  attr_reader :logger

  def self.build_mapper(model_class, &mapper_definition)
    Mapper.build_mapper(model_class, &mapper_definition)
  end

  def self.import_data(input, import_class, strategy_class, logger, options = {})
    importer = new(input, import_class, strategy_class, logger, options)
    importer.logger
  end

  def initialize(input, import_class, strategy_class, logger, options = {})
    @logger = logger

    dry_run = options.fetch(:dry_run, false)
    ignore_unmapped_columns = options.fetch(:ignore_unmapped_columns, false)

    mapper = import_class.get_mapper(strategy_class)
    valid_header = mapper.input_structure_valid?(input.get_header, ignore_unmapped_columns: ignore_unmapped_columns)

    if valid_header
      strategy = strategy_class.new(mapper)
      strategy.dry_run = dry_run
      import_data(strategy, input, mapper.model_class.name)
    else
      log_invalid_header(input, mapper)
    end
  end

  def import_data(strategy, input, import_class)
    input.each do |data|
      status = strategy.import_record(data)
      log_entry = Logger::LogEntry.new(input.input_identifier, import_class, status)
      @logger.log_import(log_entry)
    end
  end

  private

  def log_invalid_header(input, mapper)
    @logger.log_fatal input.input_identifier,
                      invalid_header_message(mapper)
  end

  def invalid_header_message(mapper)
    'Invalid Input Header - Missing Columns: ' +
      mapper.missing_columns.join(', ') +
      ' Invalid Columns: ' +
      mapper.bad_columns.join(', ')
  end

end
