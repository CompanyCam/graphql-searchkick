# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Searchkick
    class RelayResultConnection < GraphQL::Relay::BaseConnection

      def search_results
        return @results if defined? @results

        apply_pagination
        execute_search

        @results = nodes
      end

      def execute_search
        nodes.load
      end

      # must return a cursor for this object/connection pair
      def cursor_from_node(item)
        item_index = paged_nodes.index(item)

        if item_index.nil?
          raise("Can't generate cursor, item not found in connection: #{item}")
        else
          offset = item_index + 1

          if after
            offset += offset_from_cursor(after)
          elsif before
            offset += offset_from_cursor(before) - 1 - search_results.size
          end

          if first && last && first >= last
            offset += first - last
          end

          encode(offset.to_s)
        end
      end

      def page_info
        self
      end

      def has_next_page
        if first
          initial_offset = after ? offset_from_cursor(after) : 0
          return search_results.total_count > initial_offset + first
        end

        if GraphQL::Relay::ConnectionType.bidirectional_pagination && last
          return search_results.length >= last
        end
        false
      end

      def has_previous_page
        if last
          search_results.total_count >= last && search_results.size > last
        elsif GraphQL::Relay::ConnectionType.bidirectional_pagination && after
          offset_from_cursor(after) > 0
        else
          false
        end
      end

      private

        def apply_pagination
          relation = nodes
          if after
            offset = (search_offset(relation) || 0) + offset_from_cursor(after)
            relation = set_offset(relation, offset)
          end

          if before && after
            if offset_from_cursor(after) < offset_from_cursor(before)
              limit = offset_from_cursor(before) - offset_from_cursor(after) - 1
              relation = set_limit(relation, limit)
            else
              relation = set_limit(relation, 0)
            end
          elsif before
            relation = set_limit(relation, offset_from_cursor(before) - 1)
          end

          if first
            if search_limit(relation).nil? || search_limit(relation) > first
              relation = set_limit(relation, first)
            end
          end

          if last
            if search_limit(relation)
              if last <= search_limit(relation)
                offset = (search_offset(relation) || 0) + (search_limit(relation) - last)
                relation = set_offset(relation, offset)
                relation = set_limit(relation, last)
              end
            end
          end

          if max_page_size && !first && !last
            if search_limit(relation).nil? || search_limit(relation) > max_page_size
              relation = set_limit(relation, max_page_size)
            end
          end
        end

        # must return nodes for this connection after paging
        def paged_nodes
          sliced_nodes
        end

        # must return  all nodes for this connection after chopping off first and last
        def sliced_nodes
          search_results
        end

        def search_limit(relation)
          relation.limit_value
        end

        def search_offset(relation)
          relation.offset_value
        end

        def set_offset(relation, offset)
          if offset >= 0
            relation.offset(offset)
          else
            relation.offset(0)
          end
        end

        def set_limit(relation, limit)
          if limit >= 0
            relation.limit(limit)
          else
            relation.limit(0)
          end
        end

        def offset_from_cursor(cursor)
          decode(cursor).to_i
        end
    end

    GraphQL::Relay::BaseConnection.register_connection_implementation(LazySearch, RelayResultConnection)
  end
end
