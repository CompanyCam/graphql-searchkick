class UserType < GraphQL::Schema::Object
end

class QueryType < GraphQL::Schema::Object
end

class SearchkickSchema < GraphQL::Schema
  query QueryType
end
