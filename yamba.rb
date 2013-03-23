require 'sinatra'
require 'rubygems'
require 'haml'
require_relative 'database'
require_relative 'data_service'

#TODO: refactor
Database::setup_db('db/cornbrook.db')

get '/' do
  'Hello World'
end

get '/times/:stop_id' do |stop_id|
  @name = stop_id
  @stop = BusStop.find(stop_id)
  @times = @stop.stop_times[0,10]
  haml :times
end

get '/times/:stop_id/now' do |stop_id|
  seconds_since_midnight = DateTime.now.seconds_since_midnight
  data_service = DataService.new
  @items = data_service.get_times_from_db(stop_id, seconds_since_midnight)
  haml :result
end
