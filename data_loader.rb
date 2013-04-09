require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'csv_data'
require_relative 'database'

#TODO
# cleanup
# load additional files
# fix tests
# use propper logging?
# deal with times after midnight!
# rake tasks for data loading?

class DataLoader

  def initialize(csv_data=CsvData.new, invalid_csv=STDOUT)
    @csv_data = csv_data
    @logger = ActiveRecord::Base.logger
    @invalid_csv = invalid_csv
  end

  def load_data
    turn_off_active_record_logging
    print_log_message('Start loading data')
    load_stops
    print_log_message('Stops loaded successfully')
    load_stop_times
    print_log_message('Stop_times loaded successfully')
    load_trips
    print_log_message('Trips loaded successfully')
    load_routes
    print_log_message('Routes loaded successfully')
    load_calendars
    print_log_message('Calendars loaded successfully')
    print_log_message('Data loading has finished')
    turn_on_active_record_logging
  end

  def load_additional_stop_times_file(filename)
    turn_off_active_record_logging
    print_log_message('Start loading data')
    load_stop_times_fragment(@csv_data.stop_times_file(filename))
    print_log_message('Data loading has finished')
  end

  def load_stops
    @csv_data.stops.each do |stop|
      BusStop.create(:stop_id => stop['stop_id'], :stop_code => stop['stop_code'], :stop_name => stop['stop_name'], :stop_lat => stop['stop_lat'], :stop_lon => stop['stop_lon'])
    end
  end

  def load_stop_times
    print_log_message("Start loading stop_times")
    load_stop_times_fragment(@csv_data.stop_times)
    print_log_message("Stop times loaded successfully")
  end

  def load_stop_times_in_fragments(suffixes)
    suffixes.each do |suffix|
      print_log_message('Starting to load stop times fragment "' + suffix.to_s)
      fragment = @csv_data.stop_times_fragment(suffix)
      load_stop_times_fragment (fragment)
      print_log_message('Stop_times fragment ' + suffix.to_s + ' loaded successfully')
    end
  end

  def load_stop_times_fragment(fragment)
    fragment.each_with_index do |time, index|
      print_progress(index)
      begin
        departure_time = DateTime.strptime(time['departure_time'], '%T').seconds_since_midnight
        StopTime.create(:trip_id => time['trip_id'], :arrival_time => time['arrival_time'], :departure_time => departure_time, :stop_id => time['stop_id'], :stop_sequence => time['stop_sequence'])
      rescue
        @invalid_csv.puts(time)
      end
    end
  end

  def load_trips
    @csv_data.trips.each do |trip|
      Trip.create(:trip_id => trip['trip_id'], :route_id => trip['route_id'], :service_id => trip['service_id'], :trip_headsign => ['trip_headsign'])
    end
  end

  def load_routes
    @csv_data.routes.each do |route|
      Route.create(:route_id => route['route_id'], :agency_id => route['agency_id'], :route_short_name => route['route_short_name'], :route_long_name => route['route_long_name'], :route_type => route['route_type'])
    end
  end

  def load_calendars
    @csv_data.calendars.each do |calendar|
      Calendar.create(:service_id => calendar['service_id'], :monday => calendar['monday'], :tuesday => calendar['tuesday'], :wednesday => calendar['wednesday'], :thursday => calendar['thursday'], :friday => calendar['friday'], :saturday => calendar['saturday'], :sunday => calendar['sunday'], :start_date => calendar['start_date'], :end_date => calendar['end_date'])
    end
  end

  def print_log_message(message)
    puts '--------'
    puts message + ': ' + DateTime.now.strftime("%T").to_s
    puts '--------'
  end

  def print_progress(index)
    if index.remainder(1000) == 0 then
      puts 'Processing line ' + index.to_s
    end
  end

  def turn_on_active_record_logging
    ActiveRecord::Base.logger = @logger
  end

  def turn_off_active_record_logging
    ActiveRecord::Base.logger = nil
  end

end