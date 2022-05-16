# frozen_string_literal: true

require_relative './models'
require_relative './field'

class BaseObject < GraphQL::Schema::Object
  field_class Field
end

class ProjectType < BaseObject
  field :id, ID, null: false
  field :name, String, null: true
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end

class QueryType < BaseObject
  field :constant, String, null: false
  field :projects, ProjectType.connection_type, null: true, search: Project, max_page_size: 100

  def constant
    'Testing Query'
  end

  def projects
  end
end

class SearchkickSchema < GraphQL::Schema
  query QueryType
end
