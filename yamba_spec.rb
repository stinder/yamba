require './yamba'
require 'rspec'
require 'rack/test'
require 'rspec/mocks'
require_relative 'database'
require_relative 'data_loader'

set :environment, :test

describe 'The Yamba App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should access a database" do
    Database::setup_db('db/cornbrook.db')
    StopTime.first.stop_id.should eq '1800SB30291'
  end

  xit "should load cornbrook data" do
    data_loader = DataLoader.new('db/cornbrook.db')
    data_loader.load_data
  end

  xit "should load real data" do
    data_loader = DataLoader.new('db/data.db')
    data_loader.load_data
  end

end