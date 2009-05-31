require 'sinatra/base'
require 'open-uri'
require 'net/http'
require 'rack-flash'
require File.join(File.dirname(__FILE__), *%w[lib user])

class ThrottledError < StandardError ; end

class Thunder < Sinatra::Default
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public, File.join(root, 'public')
  enable :sessions

  use Rack::Flash
  
  helpers do
    def check_user(user)
      if user.exists?
        erb :show
      else
        flash[:error] = params[:username]
        redirect '/'
      end
    end
  end

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
      erb(:show)
    rescue ThrottledError
      erb :throttled
    rescue Exception => err
      check_user(@user)
    end
  end
end
