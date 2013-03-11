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
    get '/stop/1800SB30291/time/110320111400'
    last_response.should be_ok
    last_response.body.should == '[
                                    {},
                                    {},
                                    {},
                                    {},
                                    {},
                                    {},
                                    {}
                                  ]'
  end


end