require "rspec"
require 'csv'
require 'rspec/mocks'
require_relative 'data_service'

describe "Data Service" do

  it "should find appropriate stop times" do


    fake_csv = stub('CSV')
    fake_csv.stub(:read).and_return([{"stop_id"=>"42", "arrival_time"=>"05:38:00"},
                                     {"stop_id"=>"42", "arrival_time"=>"06:38:00"},
                                     {"stop_id"=>"42", "arrival_time"=>"07:38:00"},
                                     {"stop_id"=>"42", "arrival_time"=>"08:38:00"}])

    data_service = DataService.new(fake_csv)
    pp data_service.get_times(42, 1)

    #data_service.stops.count.should eq 14176
  end
end