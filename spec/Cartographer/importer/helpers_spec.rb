require 'spec_helper'

class TestImportable
  extend Importer::Helpers
end

describe Importer::Helpers do
  describe ".boolify" do
    it "returns true if given 'Yes'" do
      expect(TestImportable.boolify('Yes')).to eql true
    end

    it "returns true if given 'True'" do
      expect(TestImportable.boolify('True')).to eql true
    end

    it "returns false if given 'No'" do
      expect(TestImportable.boolify('No')).to eql false
    end

    it "returns false if given 'False'" do
      expect(TestImportable.boolify('False')).to eql false
    end

    it 'returns nil if the type is unknown' do
      expect(TestImportable.boolify('Unknown')).to be_nil
    end

    it 'returns nil if it is given a nil' do
      expect(TestImportable.boolify(nil)).to be_nil
    end
  end
end
