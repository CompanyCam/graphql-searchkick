require_relative 'lib/graphql/searchkick/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-searchkick'
  spec.version       = Graphql::Searchkick::VERSION
  spec.authors       = ['Chad Wilken']
  spec.email         = ['chad.wilken@gmail.com']

  spec.summary       = "A Searchkick plugin for graphql-ruby"
  spec.description   = "A Searchkick plugin for graphql-ruby allowing you to use searchkick with the connection type"
  spec.homepage      = "https://github.com/CompanyCam/graphql-searchkick"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake',    '~> 12.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_dependency 'graphql', '> 1.8'
  spec.add_dependency 'searchkick', '> 3.0'
end
