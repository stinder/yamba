require "rspec"
require 'rspec/mocks'
require_relative 'data_service'
require_relative 'result_item'
require_relative 'csv_data'

describe "Data Service" do

  it 'should find appropriate stop times' do

    now = DateTime.strptime('06:28:00','%T')
    fake_data = mock('CsvData')
    fake_data.stub(:stop_times).and_return([{'stop_id' => '42', 'arrival_time' => '05:38:00'},
                                     {'stop_id' => '42', 'arrival_time' => '06:28:00'},
                                     {'stop_id' => '42', 'arrival_time' => '06:38:00'},
                                     {'stop_id' => '42', 'arrival_time' => '07:38:00'},
                                     {'stop_id' => '42', 'arrival_time' => '08:38:00'}])

    data_service = DataService.new(fake_data)
    times = data_service.get_times('42', 3, now)

    times.count.should eq 3
    times[0].time_string.should eq '06:28:00'
    times[1].time_string.should eq '06:38:00'
    times[2].time_string.should eq '07:38:00'
  end

  xit 'should get me the real times' do

    data_service = DataService.new
    now = DateTime.strptime('06:28:00','%T')
    pp times = data_service.get_times('1800SB30291', 3, now)

  end
end