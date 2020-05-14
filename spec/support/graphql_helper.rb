# frozen_string_literal: true

require 'graphql'

module GraphQLHelper
  def execute_query(query, variables: nil, context: {})
    result = SearchkickSchema.execute(query, variables: variables, context: context, operation_name: nil)

    result.as_json.with_indifferent_access
  end

  def decode_cursor(cursor)
    encoder = SearchkickSchema.cursor_encoder || GraphQL::Schema::Base64Encoder
    encoder.decode(cursor.to_s, nonce: true)
  end

  def encode_cursor(cursor)
    encoder = SearchkickSchema.cursor_encoder || GraphQL::Schema::Base64Encoder
    encoder.encode(cursor.to_s, nonce: true)
  end
end
