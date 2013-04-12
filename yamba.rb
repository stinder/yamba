require 'sinatra'
require 'rubygems'
require 'haml'
require_relative 'database'
require_relative 'data_service'

DATABASE_FILE = '/tmp/data.db'
DATABASE_ZIP = 'zip/data.db.tar.gz'

#TODO: add more information (stop name, date, time)

configure do
  Database::unzip_db(DATABASE_ZIP, DATABASE_FILE)
  Database::setup_db(DATABASE_FILE)
end

get '/times/:stop_id/now' do |stop_id|
  now = DateTime.now
  seconds_since_midnight = now.seconds_since_midnight
  data_service = DataService.new
  @items = data_service.get_times_from_db(stop_id, seconds_since_midnight, now)
  haml :result
end