require 'rspec'
require 'rspec/mocks'
require_relative 'data_service'
require_relative 'result_item'
require_relative 'database'

#TODO: have a look at the routes, use exceptions

describe "Data Service" do

  before(:each) do
    db_path = 'db/test.db'
    Database::setup_db(db_path)
    Database::create_schema(db_path)
    ActiveRecord::Base.logger = nil
    @data_service = DataService.new
  end

  it 'should find appropriate stop times' do
    StopTime.create(:trip_id => '17', :departure_time => '3600',:stop_id => 'abc')
    Trip.create(:trip_id => '17', :route_id => '2',:service_id => '4' )
    Calendar.create(:service_id => '4', :sunday => '1', :tuesday => '1', :start_date => '20130101', :end_date => '20131212')

    Trip.create(:trip_id => '18', :route_id => '2',:service_id => '5' )
    Calendar.create(:service_id => '5', :sunday => '0',:tuesday => '0', :start_date => '20130101', :end_date => '20131212')

    now = DateTime.new(2013,04,02)
    items = @data_service.get_times_from_db('abc', '2500', now)

    items.count.should eq 1
    items[0].departure_time.should eq 3600
  end

  it "should only find stop_times that are valid for today's day of week" do
    StopTime.create(:trip_id => '21', :departure_time => '3600',:stop_id => 'abc')
    Trip.create(:trip_id => '21', :route_id => '2',:service_id => '12' )
    Calendar.create(:service_id => '12', :sunday => '1', :tuesday => '1', :start_date => '20130101', :end_date => '20131212')

    # day of week doesn't match
    StopTime.create(:trip_id => '19', :departure_time => '3700',:stop_id => 'abc')
    Trip.create(:trip_id => '19', :route_id => '2',:service_id => '7' )
    Calendar.create(:service_id => '7', :sunday => '0', :tuesday => '0', :start_date => '20130101', :end_date => '20131212')

    now = DateTime.new(2013,04,02)
    items = @data_service.get_times_from_db('abc', '2500', now)

    items.count.should eq 1
    items[0].departure_time.should eq 3600
  end

  it "should only find stop_times with matching calendar start and end dates" do

    StopTime.create(:trip_id => '31', :departure_time => '3600',:stop_id => 'abc')
    Trip.create(:trip_id => '31', :route_id => '2',:service_id => '1' )
    Calendar.create(:service_id => '1', :sunday => '1', :tuesday => '1', :start_date => '20130101', :end_date => '20131212')

    StopTime.create(:trip_id => '20', :departure_time => '3800',:stop_id => 'abc')
    Trip.create(:trip_id => '20', :route_id => '2',:service_id => '8' )
    Calendar.create(:service_id => '8', :sunday => '1', :tuesday => '1', :start_date => '20130601', :end_date => '20131212')

    now = DateTime.new(2013,04,02)
    items = @data_service.get_times_from_db('abc', '2500', now)

    items.count.should eq 1
    items[0].departure_time.should eq 3600
  end

  xit 'should get me the real times' do
    data_service = DataService.new
    now = DateTime.strptime('06:28:00','%T')
    pp times = data_service.get_times('1800SB30291', 3, now)
  end

end