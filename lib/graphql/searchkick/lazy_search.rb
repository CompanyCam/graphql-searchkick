# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module Searchkick
    class LazySearch
      include Enumerable
      extend Forwardable

      SEARCH_ALL = '*'.freeze

      attr_accessor :query, :model_class, :options, :limit_value, :offset_value, :elastic_sintaxe

      def_delegators :load, :results, :hits, :took, :error
      def_delegators :load, :total_count, :current_page, :total_pages, :aggs
      def_delegators :results, :first, :last, :each, :index
      def_delegators :results, :any?, :empty?, :size, :length, :slice, :[], :to_ary

      def initialize(options, query:, model_class:, elastic_sintaxe: false)
        @query =
          if query.nil? || query.empty?
            SEARCH_ALL
          else
            query
          end
        @model_class = model_class
        @options = options || {}
        @elastic_sintaxe = elastic_sintaxe

        self.limit_value = @options[:limit] if @options.key?(:limit)
        self.offset_value = @options[:offset] if @options.key?(:offset)
      end

      def load
        return @result if defined? @result

        return model_class.search(body: options, load: false ) if elastic_sintaxe

        model_class.search(query, options.merge(limit: limit_value, offset: offset_value))
      end

      def limit(value)
        clone.limit!(value)
      end

      def offset(value)
        clone.offset!(value)
      end

      def limit!(value)
        self.limit_value = value
        self
      end

      def offset!(value)
        self.offset_value = value
        self
      end
    end
  end
end
