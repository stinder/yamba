require 'rspec'
require 'rspec/mocks'
require_relative '../data_loader'

describe 'Data Loader' do

  before(:each) do
    @fake_data = double(CsvData)
    path = 'db/test.db'
    Database::setup_db(path)
    DataLoader::create_schema(path)
    @loader = DataLoader.new(@fake_data)
  end

  it 'should load bus stops into db' do
    @fake_data.stub('stops').and_return([
       {'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'},
       {'stop_id' => '2580BMT0003', 'stop_code' => 'bladgjp', 'stop_name' => 'Belmont', 'stop_lat' => '53.63858', 'stop_lon' => '-2.49405'}
     ])

    @loader.load_stops

    BusStop.all.count.should eq 2
    BusStop.find('2580BLA0027').stop_code.should eq 'bladjpj'
  end

  it 'should load stop times into db' do
    @fake_data.stub(:stop_times).and_return([
        {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04791', 'stop_sequence' => '1', 'pickup_type' => '0', 'drop_off_type' => '0'},
        {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04791', 'stop_sequence' => '1', 'pickup_type' => '0', 'drop_off_type' => '0'},
        {'trip_id' => 1, 'arrival_time' => '05:39:00', 'departure_time' => '07:18:20', 'stop_id' => '1800SB04961', 'stop_sequence' => '2', 'pickup_type' => '0', 'drop_off_type' => '0'}
    ])
    @loader.load_stop_times

    StopTime.all.count.should eq 3
    StopTime.where(:trip_id => 0).count.should eq 2
    expected_time = 7 * 60 * 60 +(18 * 60) + 20
    StopTime.where(:trip_id => 1).first.departure_time.should eq expected_time
    StopTime.where(:trip_id => 7).empty?.should be_true
  end

  it 'should load stop_times fragements' do
    @fake_data.should_receive(:stop_times_fragment).once.with(1).and_return([
      {'trip_id' => 7, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:11', 'stop_id' => '1800SB04721', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04791', 'stop_sequence' => '1', 'pickup_type' => '0', 'drop_off_type' => '0'},
    ])
    @fake_data.should_receive(:stop_times_fragment).once.with(2).and_return([
      {'trip_id' => 0, 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '1800SB04791', 'stop_sequence' => '1', 'pickup_type' => '0', 'drop_off_type' => '0'},
    ])
    @fake_data.should_receive(:stop_times_fragment).once.with(3).and_return([
      {'trip_id' => 1, 'arrival_time' => '05:39:00', 'departure_time' => '07:18:20', 'stop_id' => '1800SB04961', 'stop_sequence' => '2', 'pickup_type' => '0', 'drop_off_type' => '0'}
    ])

    @loader.load_stop_times_in_fragments(1..3)
    StopTime.all.count.should eq 4
  end

  it 'should load an additional stop_times file' do
    @fake_data.stub(:stops).and_return([{'stop_id' => '2580BLA0027', 'stop_code' => 'bladjpj', 'stop_name' => 'Blackburn', 'stop_lat' => '53.74718', 'stop_lon' => '-2.48005'}])
    @fake_data.stub(:stop_times_file).and_return([{'trip_id' => '0', 'arrival_time' => '05:38:00', 'departure_time' => '05:38:00', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'}])
    @loader.load_stops
    @loader.load_additional_stop_times_file('filename')
    BusStop.all.count.should eq 1
    StopTime.all.count.should eq 1
  end

  it 'should load all data into db' do
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

  it 'should load times after midnight' do
    @fake_data.stub(:stop_times_file).and_return([
      {'trip_id' => '0', 'arrival_time' => '24:00:01', 'departure_time' => '24:00:02', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => '1', 'arrival_time' => '00:00:24', 'departure_time' => '00:00:24', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => '2', 'arrival_time' => '24:00:02', 'departure_time' => '24:00:00', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => '3', 'arrival_time' => '24:00:01', 'departure_time' => '00:24:01', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => '5', 'arrival_time' => '24:00:01', 'departure_time' => '25:00:01', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'},
      {'trip_id' => '4', 'arrival_time' => '00:00:00', 'departure_time' => '00:00:00', 'stop_id' => '2580BLA0027', 'stop_sequence' => '0', 'pickup_type' => '0', 'drop_off_type' => '1'}
    ])
    @loader.load_additional_stop_times_file('filename')
    StopTime.all.count.should eq 6
    StopTime.where(:trip_id => '0').first.departure_time.should eq 86402
    StopTime.where(:trip_id => '1').first.departure_time.should eq 24
    StopTime.where(:trip_id => '2').first.departure_time.should eq 86400
    StopTime.where(:trip_id => '3').first.departure_time.should eq 1441
    StopTime.where(:trip_id => '4').first.departure_time.should eq 0
    StopTime.where(:trip_id => '5').first.departure_time.should eq 90001
  end

  it 'should recreate schema' do
    path = 'db/test.db'
    Database::setup_db(path)
    DataLoader::create_schema(path)
    BusStop.all.should eq []
    StopTime.all.should eq []
    Trip.all.should eq []
    Route.all.should eq []
    Calendar.all.should eq []
  end
end