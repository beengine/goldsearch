require 'sequel'
require 'pg'

# db = URI.parse(ENV['DATABASE_URL'])
# DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')

DB.create_table :articles do
  primary_key :id
  String :slug, unique: true, null: false, default: ''
  String :title, null: false
  String :body, text: true
  Integer :lang, null: false
  foreign_key :parent_id
end
