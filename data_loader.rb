require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'csv_data'
require_relative 'database'

class DataLoader

  def initialize(dbpath='db/data.db', csv_data=CsvData.new)
    @csv_data = csv_data
    @dbpath = dbpath
    Database::setup_db(dbpath)
  end

  def load_data
    load_stops
    load_stop_times
  end

  def load_stops
    @csv_data.stops.each do |stop|
      BusStop.create(:stop_id => stop['stop_id'], :stop_code => stop['stop_code'], :stop_name => stop['stop_name'], :stop_lat => stop['stop_lat'], :stop_lon => stop['stop_lon'] )
    end
  end

  def load_stop_times
    @csv_data.stop_times.each do |time|
      StopTime.create(:trip_id => time['trip_id'], :arrival_time => time['arrival_time'], :departure_time => DateTime.strptime(time['departure_time'], '%T').seconds_since_midnight, :stop_id => time['stop_id'], :stop_sequence => time['stop_sequence'] )
    end
  end

  def create_schema
    database = SQLite3::Database.open(@dbpath)
    database.execute "DROP TABLE IF EXISTS bus_stops"
    database.execute "DROP TABLE IF EXISTS stop_times"
    database.execute "CREATE TABLE bus_stops(stop_id TEXT PRIMARY KEY,  stop_code TEXT, stop_name TEXT, stop_lat NUMBER, stop_lon NUMBER)"
    database.execute "CREATE TABLE stop_times(id PRIMARY KEY,trip_id TEXT, arrival_time TEXT, departure_time NUMBER, stop_id TEXT, stop_sequence TEXT)"
    database.close if database
  end

end