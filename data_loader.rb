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
    Database::create_schema(@dbpath)
  end

  def load_data
    records = []
    load_stops(records)
    load_stop_times(records)
    load_trips(records)
    load_routes(records)
    load_calendars(records)
    save_records(records)
  end

  def save_records(records)
    ActiveRecord::Base.transaction do
      records.each { |time| time.save }
    end
  end

  def load_stops(records = [])
    @csv_data.stops.each do |stop|
      records << BusStop.new(:stop_id => stop['stop_id'], :stop_code => stop['stop_code'], :stop_name => stop['stop_name'], :stop_lat => stop['stop_lat'], :stop_lon => stop['stop_lon'] )
    end
  end

  def load_stop_times(records = [])
    @csv_data.stop_times.each do |time|
      records << StopTime.new(:trip_id => time['trip_id'], :arrival_time => time['arrival_time'], :departure_time => DateTime.strptime(time['departure_time'], '%T').seconds_since_midnight, :stop_id => time['stop_id'], :stop_sequence => time['stop_sequence'] )
    end
  end

  def load_trips(records = [])
    @csv_data.trips.each do |trip|
      records << Trip.new(:trip_id => trip['trip_id'], :route_id => trip['route_id'],:service_id => trip['service_id'], :trip_headsign => ['trip_headsign'] )
    end
  end

  def load_routes(records = [])
    @csv_data.routes.each do |route|
      records << Route.new(:route_id => route['route_id'], :agency_id => route['agency_id'],:route_short_name => route['route_short_name'], :route_long_name => route['route_long_name'], :route_type => route['route_type'] )
    end
  end

  def load_calendars(records = [])
    @csv_data.calendars.each do |calendar|
      records << Calendar.new(:service_id => calendar['service_id'], :monday => calendar['monday'],:tuesday => calendar['tuesday'], :wednesday => calendar['wednesday'], :thursday => calendar['thursday'], :friday => calendar['friday'], :saturday => calendar['saturday'], :sunday => calendar['sunday'], :start_date => calendar['start_date'], :end_date => calendar['end_date'])
    end
  end

end