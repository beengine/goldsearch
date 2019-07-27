require 'sequel'
require 'pg'

db = URI.parse(ENV['DATABASE_URL'])
DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
# DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')

DB.create_table :articles do
  primary_key :id
  String :slug, unique: true, null: false, default: ''
  String :title, null: false
  String :body
  Integer :lang, null: false
  foreign_key :parent_id
end

DB.create_table :sliders do
  primary_key :id
  String :text_en, null: false
  String :text_ua, null: false
  String :text_ru, null: false
  String :image_1, null: false
  String :image_2
  String :image_3
  String :image_4
  String :image_5
end

DB.create_table :specialties do
  primary_key :id
  String :image, null: false
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
  Integer :birthday, null: false
end

DB.create_table :engineer_translations do
  primary_key :id
  foreign_key :engineer_id, null: false
  Integer :lang, null: false
  String :slug, null: false
  String :name, null: false
  String :specialty, null: false
  String :resume, null: false
  String :desc
end

#seed

gold_uk = DB[:articles].insert(title: 'Золото', slug: 'золото', body: '<h2>Текст про золото</h2>', lang: 1)
DB[:articles].insert(title: 'Корінне Золото', slug: 'корінне-золото', body: '<h2>Текст про корінне золото</h2>', lang: 1, parent_id: gold_uk)
DB[:articles].insert(title: 'Розсипне Золото', slug: 'розсипне-золото', body: '<h2>Текст про розсипне золото</h2>', lang: 1, parent_id: gold_uk)

gold_ru = DB[:articles].insert(title: 'Золото', slug: 'золото-ru', body: '<h2>Текст про золото</h2>', lang: 2)
DB[:articles].insert(title: 'Корренное Золото', slug: 'коренное-золото', body: '<h2>Текст о коренном золоте</h2>', lang: 2, parent_id: gold_ru)
DB[:articles].insert(title: 'Роcсыпное Золото', slug: 'россыпное-золото', body: '<h2>Текст о россыпном золоте</h2>', lang: 2, parent_id: gold_ru)

salt_uk = DB[:articles].insert(title: 'Солі', slug: 'солі', body: '<h2>Текст про солі</h2>', lang: 1)
salt_ru = DB[:articles].insert(title: 'Соли', slug: 'соли', body: '<h2>Текст о солях</h2>', lang: 2)

water_uk = DB[:articles].insert(title: 'Вода', slug: 'води', body: '<h2>Текст про воду</h2>', lang: 1)
water_ru = DB[:articles].insert(title: 'Вода', slug: 'воды', body: '<h2>Текст о воде</h2>', lang: 2)

carbon_uk = DB[:articles].insert(title: 'Нафта і газ', slug: 'нафта-і-газ', body: '<h2>Текст про вуглеводні</h2>', lang: 1)
carbon_ru = DB[:articles].insert(title: 'Нефть и газ', slug: 'нефть-и-газ', body: '<h2>Текст о углеводородах</h2>', lang: 2)

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

pavliuk = DB[:engineers].insert(specialty_id: geologists,
                                birthday: 1964,
                                image: 'https://ucarecdn.com/1d704c99-7f79-414e-8423-9225eb6d821b/43118639_1983835685248129_1788644768185452739_n.jpg')

pavliuk_en = DB[:engineer_translations].insert(engineer_id: pavliuk,
                                               lang: 0,
                                               slug: 'pavliuk',
                                               name: 'Vasyl Pavliuk',
                                               specialty: 'Head of geological department for oil and gas, chief geologist',
                                               resume: "40 years of experience\nThere is some text",
                                               desc: '<p>Some text here</p>')
pavliuk_ua = DB[:engineer_translations].insert(engineer_id: pavliuk,
                                               lang: 1,
                                               slug: 'павлюк',
                                               name: 'Павлюк Василь Іванович',
                                               specialty: 'Начальник геологічного відділу з нафти і газу, головний геолог',
                                               resume: "40 років досвіду\nТут трохи тексту",
                                               desc: '<p>Тут трохи тексту</p>')
pavliuk_ru = DB[:engineer_translations].insert(engineer_id: pavliuk,
                                               lang: 2,
                                               slug: 'павлюк',
                                               name: 'Павлюк Василий Иванович',
                                               specialty: 'Начальник геологического отдела с нефти и газа, главный геолог',
                                               resume: "40 лет опыта\nТут немного текста",
                                               desc: '<p>Тут немного текста</p>')
