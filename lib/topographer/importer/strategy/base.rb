module Topographer
  class Importer
    module Strategy
      class Base

        attr_accessor :dry_run, :mapper

        def initialize(mapper)
          @mapper = mapper
          @dry_run = false
        end

        def import_record (record_input)
          raise NotImplementedError
        end

        def success_message
          'Imported'
        end

        def failure_message
          'Unable to import'
        end

        def should_persist_import?(status)
          (@dry_run || status.errors?) ? false : true
        end

        private

        def get_import_status(mapping_result, new_model_errors)
          status = Topographer::Importer::Strategy::ImportStatus.new(mapping_result.source_identifier)
          mapping_result.errors.values.each do |error|
            status.add_error(:mapping, error)
          end
          new_model_errors.each do |error|
            status.add_error(:validation, error)
          end
          status.message = (status.errors?) ? failure_message : success_message
          status.set_timestamp
          status
        end

      end
    end
  end
end
