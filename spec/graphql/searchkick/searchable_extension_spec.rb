# frozen_string_literal: true

RSpec.describe GraphQL::Searchkick::SearchableExtension do
  let(:field) do
    Field.new({
      type: UserType,
      name: :testing,
      search: Project,
      null: true
    }) do
      argument :test, GraphQL::Types::Boolean, required: false
    end
  end
  subject { described_class.new(field: field, options: { model_class: Project }) }

  describe '#apply' do
    it 'adds a `query` argument to the field' do
      expect(field.arguments).to have_key('query')
      expect(field.arguments['query'].type).to eq(GraphQL::Types::String)
    end
  end

  describe '#resolve' do
    let(:object) { Object.new }
    let(:arguments) do
      {
        query: 'Test',
        test: true
      }
    end
    let(:filters) { { where: { name: 'Banana' } } }
    let(:handler) { proc {|obj, args| filters } }

    it 'removes `query` from the arguments' do
      expect { |block|
        subject.resolve(object: object, arguments: arguments, context: {}, &block)
      }.to yield_with_args(object, { test: true })
    end

    it 'returns a LazySearch' do
      result = subject.resolve(object: object, arguments: arguments, context: {}, &handler)
      expect(result).to be_a(GraphQL::Searchkick::LazySearch)
    end

    it 'passes the options, query, and model_class to LazySearch' do
      expect(GraphQL::Searchkick::LazySearch).to receive(:new).with(filters, query: 'Test', model_class: Project)
      subject.resolve(object: object, arguments: arguments, context: {}, &handler)
    end
  end
end
