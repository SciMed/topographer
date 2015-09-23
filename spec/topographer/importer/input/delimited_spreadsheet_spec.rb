require 'spec_helper'

describe Topographer::Importer::Input::DelimitedSpreadsheet do
  let(:csv_path) do
    File.expand_path(File.join(__dir__, '../../../assets/test_files/a_csv.csv'))
  end
  let(:csv_object) do
    file = File.open(csv_path, 'r')
    CSV.new(file, headers: true)
  end
  let(:name) do
    'csv_name'
  end

  subject do
    described_class.new(name, csv_object)
  end

  describe '#get_header' do
    context 'headers read before input created' do
      let(:csv_object) do
        CSV.read(csv_path, headers: true)
      end
      it 'returns the headers that were previously read' do
        expect(subject.get_header).to eql ['header 1', 'header 2']
      end
    end
    context 'headers not read yet' do
      let(:csv_object) do
        file = File.open(csv_path, 'r')
        CSV.new(file, headers: true)
      end
      it 'returns the headers that were previously read' do
        expect(subject.get_header).to eql ['header 1', 'header 2']
      end
    end
    context 'headers will never be read' do
      let(:csv_object) do
        file = File.open(csv_path, 'r')
        CSV.new(file)
      end
      it 'returns an empty array' do
        expect(subject.get_header).to eql []
      end
    end
  end

  describe '#input_identifier' do
    it 'returns the csv name passed in' do
      expect(subject.input_identifier).to eql name
    end
  end

  describe '#each' do
    it 'yields a SourceData object for each row in the sheet' do
      expected_data = [
        {
          'header 1' => '1',
          'header 2' => '2',
        },
        {
          'header 1' => '3',
          'header 2' => 'foo'
        }
      ]
      subject.each_with_index do |source_data, index|
        expect(source_data.data).to eql expected_data[index]
      end
    end
    it 'yields the same data with multiple calls' do
      expected_data = [
        {
          'header 1' => '1',
          'header 2' => '2',
        },
        {
          'header 1' => '3',
          'header 2' => 'foo'
        }
      ]
      subject.each_with_index do |source_data, index|
        expect(source_data.data).to eql expected_data[index]
      end
      subject.each_with_index do |source_data, index|
        expect(source_data.data).to eql expected_data[index]
      end
    end
  end

end
