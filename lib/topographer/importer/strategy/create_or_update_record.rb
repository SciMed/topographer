module Topographer
  class Importer
    module Strategy
      class CreateOrUpdateRecord < Topographer::Importer::Strategy::Base

        def import_record (source_data)
          mapping_result = mapper.map_input(source_data)

          search_params = mapping_result.data.slice(*mapper.key_fields)
          model_instances = mapper.model_class.where(search_params)

          if model_instances.any?
            model_instance = model_instances.first
          else
            model_instance = mapper.model_class.new(search_params)
          end

          generate_messages(model_instance, search_params)

          model_instance.attributes = mapping_result.data
          model_instance.valid?

          model_errors = model_instance.errors.full_messages
          status = get_import_status(mapping_result, model_errors)

          model_instance.save if should_persist_import?(status)

          status
        end

        def success_message
          @success_message
        end

        def failure_message
          @failure_message
        end

        private

        def generate_messages(model_instance, search_params)
          if model_instance.new_record?
            @success_message = 'Imported record'
            @failure_message = 'Import failed'
          else
            params_string = search_params.map { |k, v| "#{k}: #{v}" }.join(', ')
            @success_message = "Updated record matching `#{params_string}`"
            @failure_message = "Update failed for record matching `#{params_string}`"
          end
        end

      end
    end
  end
end
