require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/namespace'
require 'sequel'
require 'pg'


configure do
  DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')
  LANGS = %w(анлійська українська російська)
  # db = URI.parse(ENV['DATABASE_URL'])
  # DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
end

helpers do
  def clear_params(params)
    params.reject{ |k, v| v.empty? }
  end
end

namespace '/admin' do
  set :views, settings.root + '/views/admin'
  get '/?' do
    erb :home, locals: { articles: DB[:articles], engineers: DB[:engineers], specialties: DB[:specialties] }
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
    engineer = DB[:engineers].left_join(DB[:engineer_translations]).where('engineers.id = ?', params[:id])
    locals = { engineer: engineer || {}, error: nil, specialties: DB[:specialties] }
    erb :engineer, locals: locals
  end

  post '/engineer' do
    begin
      if params[:id].empty?
        DB[:engineers].insert(clear_params(params[:engineer]))
      else
        DB[:engineers].where(id: params[:id]).update(clear_params(params[:engineer]))
      end
      redirect '/admin'
    rescue Sequel::Error => e
      erb :engineer, locals: { error: e, engineer: params[:engineer], specialties: DB[:specialties] }
    end
  end
end


get '/' do
  # slim :home, layout: false, locals: { l: settings.ua }
  erb :home, locals: { articles: DB[:articles] }
end

get '/team' do
  erb :team
end

get '/:slug' do
  erb :article, locals: { article: DB[:articles].where(slug: params[:slug]).first }
end
