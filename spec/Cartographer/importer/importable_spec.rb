require 'spec_helper'

class TestImportable
  extend Importer::Importable
end

describe Importer::Importable do
  describe "#get_mapper" do
    it 'should raise NotImplementedError' do
      expect { TestImportable.get_mapper(nil) }.to raise_error(NotImplementedError)
    end
  end
end
