# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module Searchkick
    class LazySearch
      include Enumerable
      extend Forwardable

      SEARCH_ALL = '*'.freeze

      attr_reader :query, :model_class, :options, :limit_value, :offset_value

      def_delegators :load, :results, :hits, :took, :error
      def_delegators :load, :total_count, :current_page, :total_pages
      def_delegators :results, :first, :last, :each, :index
      def_delegators :results, :any?, :empty?, :size, :length, :slice, :[], :to_ary

      def initialize(options, query:, model_class:)
        @query =
          if query.nil? || query.empty?
            SEARCH_ALL
          else
            query
          end
        @model_class = model_class
        @options = options || {}

        if @options.key?(:limit)
          @limit_value = @options[:limit]
        end
      end

      def load
        return @result if defined? @result

        @result = model_class.search(query, options.merge(limit: limit_value, offset: offset_value))

        @result
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
