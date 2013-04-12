require 'rspec'
require_relative '../database'

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

  #TODO: shit test
  it "should unzip the database and copy it to tmp" do

    zip_file = 'zip/test.db.tar.gz'

    fake_zip = double('fake_zip')
    tar_reader = mock('TAR')
    gzip_reader = mock('GZIP')
    gzip_reader.stub(:open).with(zip_file).and_return(gzip_reader)
    tar_reader.stub(:new).and_return(fake_zip)
    fake_zip.stub(:each).and_return(mock('DB'))

    Database::unzip_db(zip_file, '/tmp/test.db', tar_reader, gzip_reader)
  end
end