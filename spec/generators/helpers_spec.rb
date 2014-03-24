require_relative '../../lib/topographer/generators/helpers'

class TestClass
  include Topographer::Generators::Helpers
end

describe Topographer::Generators::Helpers do
  let(:helper) { TestClass.new }

  describe '#underscore_name' do
    it 'should return the snake case representation of input' do
      expect(helper.underscore_name('ABC')).to eql('abc')
      expect(helper.underscore_name('SnakeCaseName')).to eql('snake_case_name')
    end
  end
end
