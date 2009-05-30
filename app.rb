require 'sinatra/base'
require 'open-uri'
require File.join(File.dirname(__FILE__), *%w[lib user])

class ThrottledError < StandardError ; end

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
    begin
      @repos = @user.repos(params[:sort] || 'watchers')
      erb :show
    rescue ThrottledError
      erb :throttled
    end
  end
end
