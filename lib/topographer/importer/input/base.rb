class Topographer::Importer::Input::Base
  def get_header
    raise NotImplementedError
  end

  def input_identifier
    raise NotImplementedError
  end

  def each
    raise NotImplementedError
  end

  def importable?
    true
  end

  def failure_message
    ''
  end
end
