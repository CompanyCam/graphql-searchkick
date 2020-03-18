# frozen_string_literal: true

require_relative './models'
require_relative './field'

class ProjectType < GraphQL::Schema::Object
  field :name, String, null: true
end

class QueryType < GraphQL::Schema::Object
  field_class Field

  field :constant, String, null: false
  field :projects, ProjectType.connection_type, null: true, search: Project

  def constant
    'Testing Query'
  end
end

class SearchkickSchema < GraphQL::Schema
  query QueryType
end
