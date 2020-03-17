# frozen_string_literal: true

class Field < GraphQL::Schema::Field
  include GraphQL::Searchkick::FieldIntegration
end
