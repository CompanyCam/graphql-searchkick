# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module Searchkick
    class LazySearch
      include Enumerable
      extend Forwardable

      attr_reader :query, :model_class, :options, :limit_value, :offset_value

      def_delegators :execute_search, :hits, :took, :error
      def_delegators :execute_search, :total_count, :current_page, :total_pages
      def_delegators :results, :each, :index, :any?, :empty?, :size, :length, :slice, :[], :to_ary

      def initialize(options, query:, model_class:)
        @query = query
        @model_class = model_class
        @options = options || {}

        if @options.key?(:limit)
          @limit_value = @options[:limit]
        end
      end

      def execute_search
        return @result if defined? @result

        @result = model_class.search(query, options.merge(limit: limit_value, offset: offset_value))

        @result
      end

      def results
        execute_search.results
      end

      def limit=(val)
        @limit_value = val
      end

      def offset=(val)
        @offset_value = val
      end
    end
  end
end
