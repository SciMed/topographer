module Topographer::Generators
  class Install < Thor::Group
    include Thor::Actions
    include Helpers

    group 'topographer'

    class_option :models, type: :array, required: true

    def self.source_root
      File.expand_path("../../templates", __FILE__)
    end

    def ignored_strategy_symbols
      [:Base, :ImportStatus]
    end

    def add_strategies
      strategy_module = Topographer::Importer::Strategy
      strategy_files = []
      @strategy_classes = []
      @strategy_class_names = []
      @namespace_files = []

      strategy_module.constants(false).each do | constant_symbol |
        unless ignored_strategy_symbols.include?(constant_symbol)
          constant = strategy_module.const_get( constant_symbol )
          if constant.is_a? Class
            @strategy_classes << constant
            @strategy_class_names << constant_symbol.to_s
            filename = "#{underscore_name(constant_symbol.to_s)}.rb"

            strategy_path = subdirectory_path('strategy/', filename)
            filepath = import_path(strategy_path)
            strategy_files << strategy_path

            template('strategy_class.rb.erb', filepath, {
              class_name: constant_symbol.to_s,
              base_class_name: constant.to_s
            })
          end
        end
      end
      add_namespace_module('Strategy', strategy_files)
    end

    def add_mappings
      mapping_base_path = subdirectory_path('mappings/', 'base.rb')
      mapping_files = [mapping_base_path]

      config_file = File.join(destination_root, 'config/environment.rb')
      is_rails = File.exists?(config_file)

      if is_rails
        require_relative config_file
        require 'active_support'
        options[:models].each do |model|
          model_class = model.classify.constantize

          model_path = subdirectory_path('mappings/', "#{model.downcase}.rb")
          filepath = import_path(model_path)
          mapping_files << model_path

          template('mapping.rb.erb', filepath, {
            model_class: model_class,
            strategy_classes: @strategy_classes
          })
        end
        template('rails_mapping_base.rb.erb', import_path(mapping_base_path))
      else
        say 'Unable to generate model mappings outside of a Rails project'

        template('mapping_base.rb.erb', import_path(mapping_base_path))
      end

      add_namespace_module('Mappings', mapping_files)
    end

    def add_runners
      runner_base_path = subdirectory_path('runners/', 'base.rb')
      runner_files = [runner_base_path]

      template('runner_base.rb.erb', import_path(runner_base_path))

      @strategy_class_names.each do |strategy_class|
        filename = "#{underscore_name(strategy_class)}.rb"

        runner_path = subdirectory_path('runners/', filename)
        filepath = import_path(runner_path)
        runner_files << runner_path

        template('runner.rb.erb', filepath, {
          strategy_class: strategy_class,
          import_name: underscore_name(strategy_class)
        })
      end

      add_namespace_module('Runners', runner_files)
    end

    def add_imports
      import_base_path = subdirectory_path('.','base.rb')
      ui_import_path = subdirectory_path('.', 'user_interface_import.rb')
      commandline_import_path = subdirectory_path('.', 'commandline_import.rb')

      @namespace_files += [import_base_path, ui_import_path, commandline_import_path]

      template('import_base.rb.erb', import_path(import_base_path))
      template('user_interface_import.rb.erb', import_path(ui_import_path))
      template('commandline_import.rb.erb', import_path(commandline_import_path))
      template('imports.rb.erb', File.join('./lib/', 'imports.rb'), {
        namespace_files: @namespace_files
      })

      template('log_display.erb', File.join('./app/views/shared', '_import_log_display.html.erb'))
    end

    private
      def subdirectory_path(subdirectory, filename)
        File.join(subdirectory, filename)
      end
      def import_path(filename)
        File.join('./lib/imports/', filename)
      end

      def add_namespace_module(module_name, files)
        module_path = subdirectory_path('.', "#{module_name.downcase}.rb")
        @namespace_files << module_path

        template('namespace_module.rb.erb', import_path(module_path), {
          namespace_files: files,
          module_name: module_name
        })
      end
  end
end
