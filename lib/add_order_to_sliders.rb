require 'sequel'
require 'pg'

db = URI.parse(ENV['DATABASE_URL'])
DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)

DB.alter_table(:sliders) do
  add_column :order, Integer, default: 0
end