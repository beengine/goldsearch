require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/namespace'
require 'sinatra/config_file'
require 'sequel'
require 'pg'
require 'uri'

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
  def erb_with_locals(template, lang, locals = {})
    erb template, locals: { nav: DB[:articles].where(lang: lang).order(:id),
                            lang: lang,
                            locale: settings.langs[lang] }.merge(locals)
  end

  def highlight?(x, y)
    return unless x == y

    'pt-3 border-t-4'
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
    erb_with_locals :home, lang, sliders: DB[:sliders].order(:order), title: settings.langs[lang][:main], nav_high: slug
  end
end

TEAM_SLUGS.each_with_index do |slug, lang|
  get slug do
    erb_with_locals :team, lang, specialties: DB[:specialties].order(:id), slug: slug, title: settings.langs[lang][:header], nav_high: 'team'
  end

  get "#{slug}/:specialty" do
    specialty = DB[:specialties].where(settings.langs[lang][:slug] => params[:specialty]).first
    redirect "#{URI::encode(slug)}" unless specialty
    erb_with_locals :specialty, lang, specialty: specialty,
                                      engineers: DB[:engineers].join(:engineer_translations, engineer_id: :id).where(lang: lang, specialty_id: specialty[:id]).order(:order),
                                      slug: ENGINEER_SLUGS[lang],
                                      title: specialty[settings.langs[lang][:name]],
                                      nav_high: 'team'
  end
end

ENGINEER_SLUGS.each_with_index do |slug, lang|
  get "#{slug}/:engineer" do
    engineer = DB[:engineers].join(:engineer_translations, engineer_id: :id).where(lang: lang, slug: params[:engineer]).first
    redirect "#{URI::encode(TEAM_SLUGS[lang])}" unless engineer
    erb_with_locals :engineer, lang, engineer: engineer, slug: slug, title: engineer[:name], nav_high: 'team'
  end
end

get '/:slug' do
  params[:slug] ||= ''
  article = DB[:articles].where(slug: params[:slug]).first
  if article
    erb_with_locals :article, article[:lang], article: article, title: article[:title], nav_high: params[:slug]
  else
    redirect '/'
  end
end
