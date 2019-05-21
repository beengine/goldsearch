require 'sinatra'
require 'sequel'
require 'pg'


configure do
  DB = Sequel.connect(adapter: :postgres, database: 'gold_dev', host: 'localhost')
  LANGS = %w(анлійська українська російська)
  # db = URI.parse(ENV['DATABASE_URL'])
  # DB = Sequel.connect(adapter: :postgres, host: db.host, user: db.user, database: db.path[1..-1], password: db.password)
end

get '/' do
  # slim :home, layout: false, locals: { l: settings.ua }
  erb :home, locals: { articles: DB[:articles] }
end

get '/team' do
  erb :team
end

get '/admin' do
  erb :admin, locals: { articles: DB[:articles] }
end
get '/article' do
  locals = if params[:dup]
             { article: { body: DB[:articles].where(id: params[:id]).first[:body], lang: params[:lang].to_i }, error: nil }
           else
             { article: DB[:articles].where(id: params[:id]).first || {body: 'Текст сюди', lang: 1}, error: nil }
           end
  erb :edit, locals: locals
end

post '/article' do
  begin
    if params[:id].empty?
      DB[:articles].insert(params[:article])
    else
      DB[:articles].where(id: params[:id]).update(params[:article])
    end
    redirect '/admin'
  rescue Sequel::UniqueConstraintViolation => e
    erb :edit, locals: {error: e, article: params[:article] }
  end
end

get '/:slug' do
  erb :article, locals: { article: DB[:articles].where(slug: params[:slug]).first }
end