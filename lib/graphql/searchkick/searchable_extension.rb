# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Searchkick
    class SearchableExtension < GraphQL::Schema::FieldExtension
      def apply
        field.argument(:query, String, required: false, description: 'A search query')
      end

      def resolve(object:, arguments:, context:)
        next_args = arguments.dup
        result = yield(object, next_args)

        if defined?(ActiveRecord::Relation) && result.is_a?(ActiveRecord::Relation)
          result
        else
          model = options[:model_class]
          LazySearch.new(result, query: next_args[:query], model_class: model)
        end
      end
    end
  end
end
