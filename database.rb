require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require 'date'
require_relative 'csv_data'

#TODO: turn db methods into instance methods

TIME_PATTERN = '%T'

class BusStop < ActiveRecord::Base
  attr_accessible :stop_id, :stop_code, :stop_name, :stop_lat, :stop_lon
  has_many :stop_times, :primary_key => :stop_id, :foreign_key => :stop_id
end

class StopTime < ActiveRecord::Base
  attr_accessible :trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :pickup_type, :drop_off_type
  belongs_to :bus_stop, :primary_key => :stop_id, :foreign_key => :stop_id
  has_one :trip, :primary_key => :trip_id, :foreign_key => :trip_id
  def time_string
    (Time.new(0) + departure_time).strftime(TIME_PATTERN)
  end
end

class Trip < ActiveRecord::Base
  attr_accessible :trip_id, :route_id, :service_id, :trip_headsign
  belongs_to :stop_time, :primary_key => :trip_id, :foreign_key => :trip_id
  has_many :routes, :primary_key => :route_id, :foreign_key => :route_id
  has_one :calendar, :primary_key => :service_id, :foreign_key => :service_id

end

class Route < ActiveRecord::Base
  attr_accessible :route_id, :agency_id, :route_short_name, :route_long_name, :route_type
  belongs_to :trip, :primary_key => :route_id, :foreign_key => :route_id
end

class Calendar < ActiveRecord::Base
  DATE_PATTERN = '%Y%m%d'
  attr_accessible :service_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_date, :end_date
  def date_matches(date)
    date >= DateTime.strptime(start_date, DATE_PATTERN) && date <= DateTime.strptime(end_date, DATE_PATTERN)
  end
end

class Database
  def self.setup_db(path="db/data.db")
    puts 'Setting up database connection for ' + path
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => path)
    set :database, "sqlite3:///#{path}"
  end

end