require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/namespace'
require 'sinatra/config_file'
require 'sequel'
require 'pg'


configure do
  if development?
    DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')
    PASSWORD = 'r'
  else
    db = URI.parse(ENV['DATABASE_URL'])
    DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
    PASSWORD = ENV["PASSWORD"]
  end
  LANGS = %w(анлійська українська російська)
  TEAM_SLUGS = %w(/team /команда /наша-команда)
  ENGINEER_SLUGS = %w(/engineer /інженер /инженер)
  HOME_SLUGS = %w(/ /головна /главная)
end

config_file 'translations.yml'
enable :sessions


helpers do
  def human_age(birthday, lang)
    age = Time.new.year - birthday
    if age % 10 == 1
      "#{age} #{settings.langs[lang][:year]}"
    elsif (age - 1) % 10 < 4
      "#{age} #{settings.langs[lang][:years]}"
    else
      "#{age} #{settings.langs[lang][:yearss]}"
    end
  end
end

require './admin'

get '/sitemap.xml' do
  send_file 'public/sitemap.xml'
end

get '/robots.txt' do
  send_file 'public/robots.txt'
end

HOME_SLUGS.each_with_index do |slug, lang|
  get slug do
    erb :home, locals: { sliders: DB[:sliders].order(:order),
                         nav: DB[:articles].where(lang: lang).order(:id),
                         lang: lang,
                         locale: settings.langs[lang] }
  end
end

TEAM_SLUGS.each_with_index do |slug, lang|
  get slug do
    erb :team, locals: { nav: DB[:articles].where(lang: lang).order(:id),
                         lang: lang,
                         locale: settings.langs[lang],
                         specialties: DB[:specialties].order(:id),
                         slug: slug }
  end

  get "#{slug}/:specialty" do
    specialty = DB[:specialties].where(settings.langs[lang][:slug] => params[:specialty]).first
    engineers = DB[:engineers].join(:engineer_translations, engineer_id: :id).where(lang: lang, specialty_id: specialty[:id]).order(:order)
    erb :specialty, locals: { locale: settings.langs[lang],
                              lang: lang,
                              specialty: specialty,
                              engineers: engineers,
                              nav: DB[:articles].where(lang: lang).order(:id),
                              slug: ENGINEER_SLUGS[lang] }
  end
end

ENGINEER_SLUGS.each_with_index do |slug, lang|
  get "#{slug}/:engineer" do
    engineer = DB[:engineers].join(:engineer_translations, engineer_id: :id).where(lang: lang, slug: params[:engineer]).first
    erb :engineer, locals: { locale: settings.langs[lang],
                             lang: lang,
                             engineer: engineer,
                             nav: DB[:articles].where(lang: lang).order(:id),
                             slug: slug }
  end
end

get '/:slug' do
  params[:slug] ||= ''
  article = DB[:articles].where(slug: params[:slug]).first
  lang = article[:lang]
  erb :article, locals: { article: article, nav: DB[:articles].where(lang: lang).order(:id), locale: settings.langs[lang], lang: lang }
end
