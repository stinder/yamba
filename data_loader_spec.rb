require 'rspec'
require 'rspec/mocks'
require_relative 'data_loader'

describe "My behaviour" do

  before(:each) do
    @fake_data = mock('Data')
    path = 'db/test.db'
    Database::setup_db(path)
    @loader = DataLoader.new(path, @fake_data)
  end

  it "should load bus stops into db" do
    @fake_data.stub(:stops).and_return([
       {'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'},
       {'stop_id' => '2580BMT0003', 'stop_code' => 'bladgjp', 'stop_name' => 'Belmont', 'stop_lat' => '53.63858', 'stop_lon' => '-2.49405'}
     ])

    records = []
    @loader.load_stops(records)
    @loader.save_records(records)

    BusStop.all.count.should eq 2
    BusStop.find('2580BLA0027').stop_code.should eq 'bladjpj'
  end

  it "should load stop times into db" do
    @fake_data.stub(:stop_times).and_return([
        {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04721', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
        {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04791', 'stop_sequence' => '1', 'pickup_type' => '0', 'drop_off_type' => '0'},
        {'trip_id' => 1, 'arrival_time' => '05:39:00', 'departure_time' => '07:18:20', 'stop_id' => '1800SB04961', 'stop_sequence' => '2', 'pickup_type' => '0', 'drop_off_type' => '0'}
    ])

    records = []
    @loader.load_stop_times(records)
    @loader.save_records(records)

    pp StopTime.all
    pp
    StopTime.all.count.should eq 3
    StopTime.where(:trip_id => 0).count.should eq 2
    expected_time = 7 * 60 * 60 +(18 * 60) + 20
    StopTime.where(:trip_id => 1).first.departure_time.should eq expected_time
  end

  it "should load all data into db" do
    @fake_data.stub(:stops).and_return([{'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'}])
    @fake_data.stub(:stop_times).and_return([{'trip_id' => '0', 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'}])
    @fake_data.stub(:trips).and_return([{'trip_id' => '0', 'route_id' => '1', 'service_id' => '2'}])
    @fake_data.stub(:routes).and_return([{'route_id' => '1', 'agency_id' => '12', 'route_short_name' => '123'}])
    @fake_data.stub(:calendars).and_return([{'service_id' => '2', 'monday' => '1', 'tuesday' => '0', 'start_date' => "20130321", 'end_date' => "20130331"}])

    @loader.load_data

    BusStop.all.count.should eq 1
    BusStop.find('2580BLA0027').stop_name.should eq 'Blackburn'
    BusStop.first.stop_times.count.should eq 1
    StopTime.first.trip.service_id.should eq '2'
    Trip.first.routes.first.agency_id.should eq '12'
    Calendar.all.count.should eq 1
    Trip.first.calendar.monday.should eq '1'
    Calendar.first.date_matches(DateTime.new(2013,3,27)).should be_true
    Calendar.first.date_matches(DateTime.new(2013,3,12)).should be_false
  end
end