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

DB.create_table :specialties do
  primary_key :id
  String :image
  String :name_en, unique: true, null: false
  String :slug_en, unique: true, null: false
  String :name_ua, unique: true, null: false
  String :slug_ua, unique: true, null: false
  String :name_ru, unique: true, null: false
  String :slug_ru, unique: true, null: false
end

DB.create_table :engineers do
  primary_key :id
  foreign_key :specialty_id, null: false
  String :image
end

DB.create_table :engineer_translations do
  primary_key :id
  foreign_key :engineer_id, null: false
  Integer :lang, null: false
  String :slug, null: false
  String :name, null: false
  String :specialty, null: false
  String :resume, null: false
  String :desc, text: true
end

#seed

DB[:articles].insert(title: 'Головна', body: '<h2>Це головна сторінка, вітання!</h2>', lang: 1)
DB[:articles].insert(title: 'Main', slug: 'main', body: '<h2>Here is the main page, congrats!</h2>', lang: 0)
DB[:articles].insert(title: 'Главная', slug: 'главная', body: '<h2>Это заглавная страница, мое почтение, уважаемый господин!</h2>', lang: 2)

gold_uk = DB[:articles].insert(title: 'Золото', slug: 'золото', body: '<h2>Текст про золото</h2>', lang: 1)
DB[:articles].insert(title: 'Розсипне Золото', slug: 'розсипне-золото', body: '<h2>Текст про розсипне золото</h2>', lang: 1, parent_id: gold_uk)

gold_ru = DB[:articles].insert(title: 'Золото', slug: 'золото-ru', body: '<h2>Текст про золото</h2>', lang: 2)
DB[:articles].insert(title: 'Роcсыпное Золото', slug: 'россыпное-золото', body: '<h2>Текст о россыпном золоте</h2>', lang: 2, parent_id: gold_ru)

geologists = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Geologists', name_ua: 'Геологи', name_ru: 'Геологи',
                                     slug_en: 'geologists', slug_ua: 'геологи', slug_ru: 'геологи')
drillers = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Drillers', name_ua: 'Буровики', name_ru: 'Буровики',
                                     slug_en: 'drillers', slug_ua: 'буровики', slug_ru: 'буровики')
technologists = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Technologists', name_ua: 'Технологи', name_ru: 'Технологи',
                                     slug_en: 'technologists', slug_ua: 'технологи', slug_ru: 'технологи')
geophysics = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Geophysics', name_ua: 'Геофізики', name_ru: 'Геофизики',
                                     slug_en: 'geophysics', slug_ua: 'геофізики', slug_ru: 'геофизики')
miners = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Miners', name_ua: 'Гірняки', name_ru: 'Горняки',
                                     slug_en: 'miners', slug_ua: 'гірняки', slug_ru: 'горняки')
surveyors = DB[:specialties].insert(image: 'https://ucarecdn.com/6d6970b9-402c-4597-8a08-ca02be8affb7/9774608.jpg',
                                     name_en: 'Surveyors', name_ua: 'Геодезисти', name_ru: 'Геодезисты',
                                     slug_en: 'surveyors', slug_ua: 'геодезисти', slug_ru: 'геодезисты')
