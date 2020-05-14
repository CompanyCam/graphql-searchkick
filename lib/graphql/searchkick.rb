# frozen_string_literal: true

require 'graphql/searchkick/version'
require 'graphql/searchkick/searchable_extension'
require 'graphql/searchkick/field_integration'
require 'graphql/searchkick/lazy_search'
require 'graphql/searchkick/result_connection'


module Graphql
  module Searchkick
    class Error < StandardError; end
  end
end
