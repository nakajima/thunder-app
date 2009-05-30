require 'sinatra/base'
require 'open-uri'
require File.join(File.dirname(__FILE__), *%w[lib user])

class Thunder < Sinatra::Default
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public, File.join(root, 'public')

  get '/' do
    erb :index
  end

  get '/user' do
    redirect "/~#{params[:username]}"
  end

  get '/~:username' do
    @user = User.get(params[:username])
    @repos = @user.repos(params[:sort] || 'watchers')
    erb :show
  end
end
