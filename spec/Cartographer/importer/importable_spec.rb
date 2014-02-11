require 'spec_helper'

class TestImportable
  extend Topographer::Importer::Importable
end

describe Topographer::Importer::Importable do
  describe "#get_mapper" do
    it 'should raise NotImplementedError' do
      expect { TestImportable.get_mapper(nil) }.to raise_error(NotImplementedError)
    end
  end
end
