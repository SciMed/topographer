class Topographer::Importer::Strategy::ImportNewRecord < Topographer::Importer::Strategy::Base

  def import_record (source_data)
    mapping_result = mapper.map_input(source_data)
    new_model = mapper.model_class.new(mapping_result.data)
    new_model.valid?
    model_errors = new_model.errors.full_messages
    status = get_import_status(mapping_result, model_errors)

    new_model.save if should_persist_import?(status)

    status
  end

end


