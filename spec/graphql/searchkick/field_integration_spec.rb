# frozen_string_literal: true

RSpec.describe GraphQL::Searchkick::FieldIntegration do
  describe 'search' do
    let(:field_config) do
      {
        type: ProjectType,
        name: :testing,
        search: search,
        null: true
      }
    end
    let(:field) { Field.new(field_config) }

    describe 'is nil' do
      let(:search) { nil }
      it 'does not add the SearchableExtension if `search` keyword passed' do
        expect(field.extensions).to be_empty
      end
    end

    describe 'is not nil' do
      let(:search) { Project }
      it 'adds the SearchableExtension if `search` keyword passed' do
        expect(field.extensions.first.class).to eq(GraphQL::Searchkick::SearchableExtension)
      end
    end
  end
end
