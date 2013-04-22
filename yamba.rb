require 'sinatra'
require 'rubygems'
require 'haml'
require_relative 'database'
require_relative 'data_service'

#TODO: add more information (stop name, date, time)
Database::setup_db('db/data.db')

get '/times/:stop_id/now' do |stop_id|
  now = DateTime.now
  seconds_since_midnight = now.seconds_since_midnight
  data_service = DataService.new
  @items = data_service.get_times_from_db(stop_id, seconds_since_midnight, now)
  haml :result
end
