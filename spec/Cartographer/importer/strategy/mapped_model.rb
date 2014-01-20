class MappedModel < OpenStruct
  def self.create(params)
    self.new(params)
  end

  def first
    self
  end

  def valid?
    self.errors = OpenStruct.new(full_messages: [])
    if field_2 == 'datum2'
      true
    else
      self.errors = OpenStruct.new(full_messages: ['Field 2 is not datum2'])
      false
    end
  end

  def save
    true
  end

  def self.get_mapper
    Importer::Mapper.build_mapper(MappedModel) do |mapping|
      mapping.required_mapping 'Field1', 'field_1'
      mapping.required_mapping 'Field2', 'field_2'
      mapping.optional_mapping 'Field3', 'field_3'
      mapping.key_field 'field_1'
      mapping.key_field 'field_2'
    end
  end

  def self.where(params)
    return self.new(params)
  end

  def self.find_or_initialize_by(params)
    return self.new(params)
  end
end
