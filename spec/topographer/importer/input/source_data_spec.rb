require 'spec_helper'

describe Topographer::Importer::Input::SourceData do

  let(:with_no_data) do
    Topographer::Importer::Input::SourceData.new("foo", {})
  end

  let(:with_data) do
    Topographer::Importer::Input::SourceData.new("foo", {bar: 'baz'})
  end

  describe '#empty?' do
    it 'should return true if there is no data' do
      expect(with_no_data.empty?).to be_true
    end
    it 'should return false if there is data' do
      expect(with_data.empty?).to be_false
    end
  end

end
