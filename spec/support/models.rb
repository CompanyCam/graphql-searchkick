# frozen_string_literal: true

require 'active_record'
require 'searchkick'

ActiveRecord::Base.logger = $logger

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :projects do |t|
  t.string :name
end

class Project < ActiveRecord::Base
  searchkick
end
