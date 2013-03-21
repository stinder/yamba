require './yamba'
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'The Yamba App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  xit "should return some times" do
  end

end