class Topographer::Importer::Strategy::UpdateRecord < Topographer::Importer::Strategy::Base

  def import_record (source_data)
    mapping_result = mapper.map_input(source_data)

    search_params = mapping_result.data.slice(*mapper.key_fields)
    model_instance = mapper.model_class.where(search_params).first

    if model_instance
      model_instance.attributes = mapping_result.data
      model_instance.valid?
      model_errors = model_instance.errors.full_messages
      status = get_import_status(mapping_result, model_errors)

      model_instance.save if should_persist_import?(status)
    else
      status = get_import_status(mapping_result, ["Record not found with params: #{search_params.to_yaml}"])
    end

    status
  end

  def success_message
    'Updated'
  end

  def failure_message
    'Unable to update from import'
  end

end


