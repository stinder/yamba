require "rspec"
require 'rspec/mocks'
require_relative 'database'

describe "Database" do

  before(:each) do
    @fake_data = mock('Data')
    @database = Database.new('db/test.db', @fake_data)
    @database.open_connection
  end

  after(:each) do
    @database.close_connection
  end

  it "should recreate database" do
    @database.create_schema
    BusStop.all.should eq []
    StopTime.all.should eq []
  end

  it "should load bus stops into db" do

    @fake_data.stub(:stops).and_return([
              {'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'},
              {'stop_id' => '2580BMT0003', 'stop_code' => 'bladgjp', 'stop_name' => 'Belmont', 'stop_lat' => '53.63858', 'stop_lon' => '-2.49405'}])

    @database.create_schema
    @database.load_stops

    BusStop.all.count.should eq 2
    BusStop.find('2580BLA0027').stop_code.should eq 'bladjpj'
  end

  it "should load stop times into db" do

    @fake_data.stub(:stop_times).and_return([
       {'trip_id'=>0, 'arrival_time'=>'05:38:00', 'departure_time'=>'05:38:00', 'stop_id'=>'1800SB04721', 'stop_sequence'=>'0', 'pickup_type'=>'0', 'drop_off_type'=>'1'},
       {'trip_id'=>0, 'arrival_time'=>'05:38:00', 'departure_time'=>'05:38:00', 'stop_id'=>'1800SB04791', 'stop_sequence'=>'1', 'pickup_type'=>'0', 'drop_off_type'=>'0'},
       {'trip_id'=>1, 'arrival_time'=>'05:39:00', 'departure_time'=>'05:39:00', 'stop_id'=>'1800SB04961', 'stop_sequence'=>'2', 'pickup_type'=>'0', 'drop_off_type'=>'0'}
      ])

    @database.create_schema
    @database.load_stop_times

    StopTime.all.count.should eq 3
    StopTime.where(:trip_id => 0).count.should eq 2
  end

  it "should load all data into db" do

    @fake_data.stub(:stops).and_return([{'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'}])
    @fake_data.stub(:stop_times).and_return([{'trip_id'=>0, 'arrival_time'=>'05:38:00', 'departure_time'=>'05:38:00', 'stop_id'=>'2580BLA0027', 'stop_sequence'=>'0', 'pickup_type'=>'0', 'drop_off_type'=>'1'}])

    @database.create_schema
    @database.load_data

    BusStop.all.count.should eq 1
    BusStop.find('2580BLA0027').stop_name.should eq 'Blackburn'
    BusStop.first.stop_times.count.should eq 1
  end

end