module Topographer::Generators
  class Install < Thor::Group
    include Thor::Actions
    include Helpers

    group 'topographer'

    class_option :models, type: :array, required: true

    def self.source_root
      File.expand_path("../../templates", __FILE__)
    end

    def add_strategies
      strategy_module = Topographer::Importer::Strategy
      strategy_files = []

      strategy_module.constants(false).each do | constant_symbol |
        if constant_symbol != :Base
          constant = strategy_module.const_get( constant_symbol )
          if constant.is_a? Class

            filename = "#{underscore_name(constant_symbol.to_s)}.rb"
            filepath = strategy_path(filename)

            strategy_files << File.join('strategy/', filename)

            template('strategy_class.rb.erb', filepath, {
              class_name: constant_symbol.to_s,
              base_class_name: constant.to_s
            })
          end
        end
      end

      template('namespace_module.rb.erb', import_path('strategy.rb'), {
        namespace_files: strategy_files,
        module_name: 'Strategy'
      })
    end

    def add_mappings
      mapping_files = []

      #TODO generate mapping files here for models passed in as args

      template('namespace_module.rb.erb', import_path('mappings.rb'), {
        namespace_files: mapping_files,
        module_name: 'Mappings'
      })
    end

    private
      def strategy_path(filename)
        File.join('./lib/imports/strategy/', filename)
      end
      def import_path(filename)
        File.join('./lib/imports/', filename)
      end
  end
end
