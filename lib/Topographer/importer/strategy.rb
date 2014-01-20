module Importer::Strategy
  require_relative 'strategy/base'
  require_relative 'strategy/import_new_record'
  require_relative 'strategy/update_record'
  require_relative 'strategy/create_or_update_record'
  require_relative 'strategy/import_status'
end
