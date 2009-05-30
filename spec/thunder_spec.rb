require File.dirname(__FILE__) + '/spec_helper'

describe "app" do
  before(:each) do
    Sinatra::Base.set :environment, :test
    @app = Thunder
  end

  it "works" do
    get '/'
    response.status.should == 200
  end
end
