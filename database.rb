require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'csv_data'

class BusStop < ActiveRecord::Base
  attr_accessible :stop_id, :stop_code, :stop_name, :stop_lat, :stop_lon
  has_many :stop_times, :primary_key => :stop_id, :foreign_key => :stop_id
end

class StopTime < ActiveRecord::Base
  attr_accessible :trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :pickup_type, :drop_off_type
end

class Database

  def initialize(path="db/data.db", csv_data=CsvData.new)
    @path = path
    @csv_data = csv_data
    setup_db_connection
  end

  def load_data
    open_connection
    load_stops
    load_stop_times
    close_connection
  end

  def load_stops
    @csv_data.stops.each do |stop|
      BusStop.create(:stop_id => stop['stop_id'], :stop_code => stop['stop_code'], :stop_name => stop['stop_name'], :stop_lat => stop['stop_lat'], :stop_lon => stop['stop_lon'] )
    end
  end

  def load_stop_times
    @csv_data.stop_times.each do |stop|
      StopTime.create(:trip_id => stop['trip_id'], :arrival_time => stop['arrival_time'], :departure_time => stop['departure_time'], :stop_id => stop['stop_id'], :stop_sequence => stop['stop_sequence'] )
    end
  end

  def close_connection
    @database.close if database
  end

  def open_connection
    @database = SQLite3::Database.open(@path)
  end

  def create_schema
    open_connection
    @database.execute "DROP TABLE IF EXISTS bus_stops"
    @database.execute "DROP TABLE IF EXISTS stop_times"
    @database.execute "CREATE TABLE bus_stops(stop_id TEXT PRIMARY KEY,  stop_code TEXT, stop_name TEXT, stop_lat NUMBER, stop_lon NUMBER)"
    @database.execute "CREATE TABLE stop_times(id PRIMARY KEY,trip_id TEXT, arrival_time TEXT, departure_time TEXT, stop_id TEXT, stop_sequence TEXT)"
    close_connection
  end

  private

  def setup_db_connection
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',:dbfile => @path)
    set :database, "sqlite3:///#{@path}"
  end

end