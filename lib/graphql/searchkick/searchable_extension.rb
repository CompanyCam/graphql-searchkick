# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Searchkick
    class SearchableExtension < GraphQL::Schema::FieldExtension
      SEARCH_ALL = '*'.freeze

      def apply
        field.argument(:query, String, required: false, description: 'A search query')
      end

      def resolve(object:, arguments:, context:)
        next_args = arguments.dup
        query = next_args.delete(:query)
        result = yield(object, next_args)

        model = options[:model_class]
        LazySearch.new(result, query: query, model_class: model)
      end
    end
  end
end
