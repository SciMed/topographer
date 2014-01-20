module Importer::Importable
  def get_mapper(strategy)
    raise NotImplementedError
  end
end
