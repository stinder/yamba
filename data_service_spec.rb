require "rspec"
require 'rspec/mocks'
require_relative 'data_service'
require_relative 'result_item'
require_relative 'database'

describe "Data Service" do

  xit 'should find appropriate stop times' do
    Database::setup_db('db/cornbrook.db')
    data_service = DataService.new
    items = data_service.get_times_from_db('1800SB30291', 80000)
  end

  xit 'should get me the real times' do
    data_service = DataService.new
    now = DateTime.strptime('06:28:00','%T')
    pp times = data_service.get_times('1800SB30291', 3, now)
  end

end