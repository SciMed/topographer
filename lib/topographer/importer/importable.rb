module Topographer
  class Importer
    module Importable
      def get_mapper(strategy)
        raise NotImplementedError
      end
    end
  end
end
