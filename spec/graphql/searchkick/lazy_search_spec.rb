# frozen_string_literal: true

RSpec.describe GraphQL::Searchkick::LazySearch do
  let(:query) { 'Test' }
  let(:model_class) { double('model').as_null_object }
  let(:options) { { limit: 10 } }
  let(:search_instance) { described_class.new(options, query: query, model_class: model_class) }

  describe '#initialize' do
    context 'nil query' do
      let(:query) { nil }

      it 'sets query to "*" if query is nil' do
        expect(search_instance.query).to eq(GraphQL::Searchkick::LazySearch::SEARCH_ALL)
      end
    end

    context 'empty string query' do
      let(:query) { '' }

      it 'sets query to "*" if query is empty string' do
        expect(search_instance.query).to eq(GraphQL::Searchkick::LazySearch::SEARCH_ALL)
      end
    end

    context 'nil options' do
      let(:options) { nil }
      it 'sets the options to an empty hash' do
        expect(search_instance.options).to eq({})
      end
    end

    context 'options has limit' do
      it 'sets the limit value' do
        expect(search_instance.limit_value).to eq(10)
      end
    end
  end

  describe 'limit setter' do
    it 'sets the limit_value' do
      expect(search_instance.limit(200).limit_value).to eq(200)
    end
  end

  describe 'offset setter' do
    it 'sets the offset_value' do
      expect(search_instance.offset(200).offset_value).to eq(200)
    end
  end

  describe '#load' do
    it 'calls #search on the model_class' do
      expect(model_class).to receive(:search).with(query, { limit: 10, offset: nil })
      search_instance.load
    end

    it 'caches the result' do
      expect(model_class).to receive(:search).with(query, { limit: 10, offset: nil }).once
      search_instance.load
      search_instance.load
    end
  end
end
