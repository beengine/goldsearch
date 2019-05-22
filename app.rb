require 'sinatra'
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
             { article: { body: DB[:articles].where(id: params[:id]).first[:body], lang: params[:lang].to_i }, error: nil, articles: DB[:articles].where(parent_id: nil) }
           else
             { article: DB[:articles].where(id: params[:id]).first || {body: 'Текст сюди', lang: 1}, error: nil, articles: DB[:articles].where(parent_id: nil) }
           end
  erb :edit, locals: locals
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
    erb :edit, locals: {error: e, article: params[:article], articles: DB[:articles] }
  end
end

get '/:slug' do
  erb :article, locals: { article: DB[:articles].where(slug: params[:slug]).first }
end
