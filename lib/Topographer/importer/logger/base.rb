class Importer::Logger::Base

  attr_reader :fatal_errors

  def initialize
    @fatal_errors = []
  end

  def successes
    raise NotImplementedError
  end

  def failures
    raise NotImplementedError
  end

  def log_import(log_entry)
    if log_entry.success?
      log_success(log_entry)
    else
      log_failure(log_entry)
    end
  end

  def log_success(log_entry)
    raise NotImplementedError
  end

  def log_failure(log_entry)
    raise NotImplementedError
  end

  def log_fatal(source, message)
    @fatal_errors << Importer::Logger::FatalErrorEntry.new(source, message)
  end

  def successful_imports
    raise NotImplementedError
  end

  def failed_imports
    raise NotImplementedError
  end

  def entries?
    total_imports > 0
  end

  def total_imports
    (successful_imports + failed_imports)
  end

  def all_entries
    (successes + failures + fatal_errors).sort {|a, b| a.timestamp <=> b.timestamp}
  end

  def errors?
    fatal_error? || failed_imports > 0
  end

  def fatal_error?
    @fatal_errors.any?
  end

  def save
    raise NotImplementedError
  end

end
