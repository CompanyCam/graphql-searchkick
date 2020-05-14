# Graphql::Searchkick

Integrate Searchkick with GraphQL Connections easily.

[![Gem Version](https://badge.fury.io/rb/graphql-searchkick.svg)](https://badge.fury.io/rb/graphql-searchkick)
[![Build Status](https://travis-ci.org/CompanyCam/graphql-searchkick.svg?branch=master)](https://travis-ci.org/CompanyCam/graphql-searchkick)
[![Maintainability](https://api.codeclimate.com/v1/badges/1102df197f6f271b9885/maintainability)](https://codeclimate.com/github/CompanyCam/graphql-searchkick/maintainability)

## Note

The current version of the gem only works with `GraphQL::Pagination::Connection` . If you need support for the older `GraphQL::Relay::BaseConnection` version use v0.1.0.

## Considerations & Limits

- This will run _every_ usage of this field through Searchkick.
- The current implementation doesn't support suggestions or aggregations.

If you find any of these undesirable, open an issue or PR.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-searchkick'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install graphql-searchkick

## Setup

Include the field integration into your field class.

```ruby
class BaseField < GraphQL::Schema::Field
  include GraphQL::Searchkick::FieldIntegration
end
```

Add the connection to your schema.

```ruby
class Schema < GraphQL::Schema
  use GraphQL::Pagination::Connections
  connections.add(GraphQL::Searchkick::LazySearch, GraphQL::Searchkick::ResultConnection)
end
```

## Usage

Add `search: ModelClass` to any connection field that you want to allow querying.

```ruby
field :projects, Types::ProjectType.connection_type, null: false, search: Project
```

Your field will now have an optional `query` argument of type `String` as part of it's definition.

If `query` is `nil?` or `empty?` the default value `'*'` is used.

### Search Arguments

If you would like to pass options to the `search` method, override the resolver for the field that returns a `Hash`.

```ruby
def projects(arguments)
  {
    where: {
      active: arguments[:active],
      coordinates: {
        near: arguments[:coords],
        within: '1km'
      }
    }
  }
end
```

This will translate into:

```ruby
Project.search('*', where: { active: true, coordinates: { near: { lat: 40.815110, lon: -96.709523 }, within: '1km' } })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `docker-compose up` to start Elasticsearch. Finally, run `bundle exec appraisal rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CompanyCam/graphql-searchkick.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
