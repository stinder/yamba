require 'rspec'
require_relative 'database'

describe "Database" do

  it "should recreate schema" do
    path = 'db/test.db'
    Database::setup_db(path)
    Database::create_schema(path)
    BusStop.all.should eq []
    StopTime.all.should eq []
    Trip.all.should eq []
    Route.all.should eq []
    Calendar.all.should eq []
  end
end