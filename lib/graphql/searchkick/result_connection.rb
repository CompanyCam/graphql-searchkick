# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Searchkick
    class ResultConnection < GraphQL::Relay::BaseConnection

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
          if after
            offset = (search_offset(nodes) || 0) + offset_from_cursor(after)
            set_offset(nodes, offset)
          end

          if before && after
            if offset_from_cursor(after) < offset_from_cursor(before)
              limit = offset_from_cursor(before) - offset_from_cursor(after) - 1
              set_limit(nodes, limit)
            else
              set_limit(nodes, 0)
            end
          elsif before
            set_limit(nodes, offset_from_cursor(before) - 1)
          end

          if first
            if search_limit(nodes).nil? || search_limit(nodes) > first
              set_limit(nodes, first)
            end
          end

          if last
            if search_limit(nodes)
              if last <= search_limit(nodes)
                offset = (search_offset(nodes) || 0) + (search_limit(nodes) - last)
                set_offset(nodes, offset)
                set_limit(nodes, last)
              end
            end
          end

          if max_page_size && !first && !last
            if search_limit(nodes).nil? || search_limit(nodes) > max_page_size
              set_limit(nodes, max_page_size)
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

        def search_limit(lazy_search)
          lazy_search.limit_value
        end

        def search_offset(lazy_search)
          lazy_search.offset_value
        end

        def set_offset(relation, offset)
          if offset >= 0
            relation.offset = offset
          else
            relation.offset = 0
          end
        end

        def set_limit(relation, limit)
          if limit >= 0
            relation.limit = limit
          else
            relation.limit = 0
          end
        end

        def offset_from_cursor(cursor)
          decode(cursor).to_i
        end
    end

    GraphQL::Relay::BaseConnection.register_connection_implementation(LazySearch, ResultConnection)
  end
end
