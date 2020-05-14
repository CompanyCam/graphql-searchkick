# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Searchkick
    class ResultConnection < GraphQL::Pagination::RelationConnection

      def has_next_page
        if @has_next_page.nil?
          @has_next_page = if @before_offset && @before_offset > 0
            true
          elsif first
            initial_offset = after && offset_from_cursor(after) || 0
            nodes.total_count > initial_offset + first
          else
            false
          end
        end
        @has_next_page
      end

      def relation_count(relation)
        relation.total_count
      end

      def relation_limit(relation)
        relation.limit_value
      end

      def relation_offset(relation)
        relation.offset_value
      end

      def null_relation(relation)
        relation.limit(0)
      end

      def load_nodes
        @nodes ||= limited_nodes
      end

    end
  end
end
