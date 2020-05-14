# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module Searchkick
    class LazySearch
      include Enumerable
      extend Forwardable

      SEARCH_ALL = '*'.freeze

      attr_reader :query, :model_class, :options, :values

      def_delegators :load, :results, :hits, :took, :error
      def_delegators :load, :total_count, :current_page, :total_pages
      def_delegators :results, :first, :last, :each, :index
      def_delegators :results, :any?, :empty?, :size, :length, :slice, :[], :to_ary

      def initialize(options, query:, model_class:)
        @values = {}

        @query =
          if query.nil? || query.empty?
            SEARCH_ALL
          else
            query
          end
        @model_class = model_class
        @options = options || {}

        if @options.key?(:limit)
          self.limit_value = @options[:limit]
        end
      end

      def load
        return @result if defined? @result

        @result = model_class.search(query, options.merge(limit: limit_value, offset: offset_value))

        @result
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

      def limit_value=(value)
        set_value(:limit, value)
      end

      def limit_value
        get_value(:limit)
      end

      def offset_value=(value)
        set_value(:offset, value)
      end

      def offset_value
        get_value(:offset)
      end

      def set_value(name, value)
        @values[name] = value
      end

      def get_value(name)
        @values[name]
      end
    end
  end
end
