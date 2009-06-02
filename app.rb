$:.unshift *Dir[File.dirname(__FILE__) + "/vendor/*/lib"]

require 'sinatra/base'
require 'open-uri'
require 'net/http'
require 'rack-flash'
require 'activerecord'
require 'delayed_job'
require 'typhoeus'
require 'logger'
require File.join(File.dirname(__FILE__), *%w[lib user])

class ThrottledError < StandardError ; end

class Thunder < Sinatra::Default
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public, File.join(root, 'public')
  enable :sessions

  use Rack::Flash

  configure do
    config = YAML::load(File.open('config/database.yml'))
    environment = Sinatra::Application.environment.to_s
    ActiveRecord::Base.logger = Logger.new($stdout)
    ActiveRecord::Base.establish_connection(
      config[environment]
    )
  end

  helpers do
    def check_user(user)
      if user.exists?
        @repos = user.repos
        @repos ? erb(:show) : erb(:loading)
      else
        flash[:error] = params[:username]
        redirect '/'
      end
    end
  end

  get '/' do
    status(404) if flash.has?(:error)
    erb :index
  end

  get '/user' do
    if params[:username].empty?
      flash[:invalid] = "invalid"
      redirect '/'
    end

    redirect "/~#{params[:username]}"
  end

  get '/ping/~:username' do
    @user = User.get(params[:username])
    @user.loaded? ? "/~#{@user.name}" : ''
  end

  get '/~:username?' do
    @user = User.get(params[:username])

    return erb(:loading) unless @user.loaded?

    begin
      @repos = @user.repos
      erb(:show)
    rescue ThrottledError
      erb :throttled
    rescue Exception => err
      check_user(@user)
    end
  end
end
