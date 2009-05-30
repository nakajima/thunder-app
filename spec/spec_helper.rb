require 'rubygems'
require 'spec'
require 'rack/test'
require File.join(File.dirname(__FILE__), *%w[.. app.rb])

module Helpers
  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Sinatra::Base, &block)
    @app = Sinatra.new(base, &block)
  end

  def app
    Rack::Lint.new(@app)
  end

  def response
   last_response
  end
end

Spec::Runner.configure do |c|
  c.include Rack::Test::Methods
  c.include Helpers
end
