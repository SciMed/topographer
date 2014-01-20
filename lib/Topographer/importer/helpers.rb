module Importer::Helpers
  require_relative 'helpers/write_log_to_csv'

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
