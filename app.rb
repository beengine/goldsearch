require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/namespace'
require 'sinatra/config_file'
require 'sequel'
require 'pg'


configure do
  # DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')
  LANGS = %w(анлійська українська російська)
  TEAM_SLUGS = %w(/team /команда /наша-команда)
  ENGINEER_SLUGS = %w(/engineer /інженер /инженер)
  HOME_SLUGS = %w(/ /головна /главная)
  db = URI.parse(ENV['DATABASE_URL'])
  DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
end

config_file 'translations.yml'
enable :sessions

helpers do
  def clear_params(params)
    params.reject{ |k, v| v.empty? }
  end

  def get_translations(locals, engineer_id)
    if engineer_id
      translations = DB[:engineer_translations].where(engineer_id: engineer_id)
      locals[:translations] = translations
    end
  end

  def authenticate
    redirect '/admin/login' unless session[:login]
  end

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

namespace '/admin' do
  set :views, settings.root + '/views/admin'
  before  { authenticate unless request.path_info == '/admin/login' }

  get '/?' do
    engineers = DB['SELECT engineers.id, engineers.image, engineer_translations.name, engineer_translations.lang FROM engineers LEFT OUTER JOIN engineer_translations ON engineer_translations.engineer_id = engineers.id'].all.group_by{ |tr| tr[:id] }
    erb :home, locals: { articles: DB[:articles], engineers: engineers, specialties: DB[:specialties].order(:id), sliders: DB[:sliders] }
  end

  get '/login' do
    redirect '/admin' if session[:login]
    erb :login
  end

  post '/login' do
    session[:login] = true if params[:password] == ENV["PASSWORD"]
    redirect '/admin'
  end

  get '/logout' do
    session[:login] = false
    redirect '/'
  end

  get '/article' do
    locals = if params[:dup]
               { article: { body: DB[:articles].where(id: params[:id]).first[:body], lang: params[:lang].to_i }, error: nil, articles: DB[:articles].where(parent_id: nil) }
             else
               { article: DB[:articles].where(id: params[:id]).first || {body: 'Текст сюди', lang: 1}, error: nil, articles: DB[:articles].where(parent_id: nil) }
             end
    erb :article, locals: locals
  end

  post '/article' do
    begin
      if params[:id].empty?
        DB[:articles].insert(clear_params(params[:article]))
      else
        DB[:articles].where(id: params[:id]).update(clear_params(params[:article]))
      end
      redirect '/admin'
    rescue Sequel::Error => e
      erb :article, locals: { error: e, article: params[:article], articles: DB[:articles] }
    end
  end

  get '/specialty' do
    locals = { specialty: DB[:specialties].where(id: params[:id]).first || {}, error: nil }
    erb :specialty, locals: locals
  end

  post '/specialty' do
    begin
      if params[:id].empty?
        DB[:specialties].insert(clear_params(params[:specialty]))
      else
        DB[:specialties].where(id: params[:id]).update(clear_params(params[:specialty]))
      end
      redirect '/admin'
    rescue Sequel::Error => e
      erb :specialty, locals: { error: e, specialty: params[:specialty] }
    end
  end

  get '/engineer' do
    locals = {
      engineer: DB[:engineers].where(id: params[:id]).first || {},
      error: nil,
      specialties: DB[:specialties]
    }
    get_translations(locals, params[:id])
    erb :engineer, locals: locals
  end

  post '/engineer' do
    begin
      if params[:id].empty?
        params[:id] = DB[:engineers].insert(clear_params(params[:engineer]))
      else
        DB[:engineers].where(id: params[:id]).update(clear_params(params[:engineer]))
      end
      redirect "/admin/engineer?id=#{params[:id]}"
    rescue Sequel::Error => e
      erb :engineer, locals: { error: e, engineer: params[:engineer], specialties: DB[:specialties] }
    end
  end

  get '/engineer_translation' do
    locals = {
      engineer: DB[:engineers].where(id: params[:id]).first || {},
      translation: DB[:engineer_translations].where(id: params[:id]).first || {lang: params[:lang].to_i, engineer_id: params[:engineer_id] },
      error: nil
    }
    erb :engineer_translation, locals: locals
  end

  post '/engineer_translation' do
    begin
      if params[:id].empty?
        DB[:engineer_translations].insert(clear_params(params[:engineer_translation]))
      else
        DB[:engineer_translations].where(id: params[:id]).update(clear_params(params[:engineer_translation]))
      end
      redirect "/admin/engineer?id=#{params[:engineer_translation][:engineer_id]}"
    rescue Sequel::Error => e
      locals = {
        engineer: DB[:engineers].where(id: params[:engineer_translation][:engineer_id]).first,
        translation: params[:engineer_translation],
        error: e
      }
      get_translations(locals, params[:engineer_translation][:engineer_id])
      erb :engineer_translation, locals: locals
    end
  end

  get '/slider' do
    locals = {
      slider: DB[:sliders].where(id: params[:id]).first || {},
      error: nil
    }
    erb :slider, locals: locals
  end

  post '/slider' do
    begin
      if params[:id].empty?
        params[:id] = DB[:sliders].insert(clear_params(params[:slider]))
      else
        DB[:sliders].where(id: params[:id]).update(clear_params(params[:slider]))
      end
      redirect "/admin"
    rescue Sequel::Error => e
      erb :slider, locals: { error: e, slider: params[:slider] }
    end
  end
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
    engineers = DB[:engineers].join(:engineer_translations, engineer_id: :id).where(lang: lang, specialty_id: specialty[:id])
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
