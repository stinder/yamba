require 'sinatra'
require 'sinatra/base'
require 'active_record'
require 'sinatra/activerecord'
require 'rubygems'
require 'haml'
require_relative 'data_service'
require 'pg'
require 'open-uri'
require 'uri'
require_relative 'lookup_service'
require 'tzinfo'
require 'sinatra/cookies'
require_relative 'recent_stop_service'


class Yamba < Sinatra::Base

  helpers Sinatra::Cookies

  $timezone = TZInfo::Timezone.get('Europe/London')

  configure :development do
    puts 'Setting up database connection for ' + 'db/data.db'
    Database::setup_db
    puts '..done'
  end

  configure :production do
    puts 'Setting up database connection for production'
    db = URI.parse(ENV['DATABASE_URL'])
    ActiveRecord::Base.establish_connection(
        :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :host => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1],
        :encoding => 'utf8'
    )
  end

  get '/times/:stop_id/now' do |stop_id|
    now = $timezone.now
    seconds_since_midnight = now.seconds_since_midnight
    data_service = DataService.new
    @items = data_service.get_times_from_db(stop_id, seconds_since_midnight, now)
    new_cookie = recent_stop_service.create_cookie_with_additional_bus_stop(request, stop_id)
    response.set_cookie('yamba', new_cookie)
    haml :result
  end

  get '/' do
    @recent_stops = recent_stop_service.get_recent_stops(request)
    haml :home
  end

  get '/lookup' do
    radius = params[:radius] || 1.2
    @bus_stops = lookup_service.lookup_locations(params[:postcode], radius)
    haml :locations
  end

  get '/lookup/:postcode' do |postcode|
    @bus_stops = lookup_service.lookup_locations(postcode)
    haml :locations
  end

  get '/remove/:stop_id' do |stop_id|
    new_cookie = recent_stop_service.create_cookie_without_bus_stop(request, stop_id)
    response.set_cookie('yamba', new_cookie)
    redirect '/'
  end

  def lookup_service
    LookupService.new
  end

  def recent_stop_service
    RecentStopService.new
  end

end





