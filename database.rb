require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/activerecord'
require 'date'
require_relative 'csv_data'

TIME_PATTERN = '%T'

class BusStop < ActiveRecord::Base
  attr_accessible :stop_id, :stop_code, :stop_name, :stop_lat, :stop_lon
  has_many :stop_times, :primary_key => :stop_id, :foreign_key => :stop_id
end

class StopTime < ActiveRecord::Base
  attr_accessible :trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :pickup_type, :drop_off_type
  belongs_to :bus_stop, :primary_key => :stop_id, :foreign_key => :stop_id

  def time_string
    parse_time.strftime(TIME_PATTERN)
  end

  def parse_time
    Time.new(0) + departure_time
  end

end

class Database

  def self.setup_db(path="db/sample.db")
    @path = path
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => @path)
    set :database, "sqlite3:///#{@path}"
  end

end