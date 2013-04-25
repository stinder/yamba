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


class Yamba < Sinatra::Base

  configure :development do
    #require 'sqlite3'
    puts 'Setting up database connection for ' + 'db/data.db'
    Database::setup_db
    puts '..done'
  end

  configure :production do
    puts 'Setting up database connection for production'
    db = URI.parse(ENV['DATABASE_URL'])
    ActiveRecord::Base.establish_connection(
        :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :host     => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1],
        :encoding => 'utf8'
    )
  end

  get '/times/:stop_id/now' do |stop_id|

    now = DateTime.now
    seconds_since_midnight = now.seconds_since_midnight
    data_service = DataService.new
    @items = data_service.get_times_from_db(stop_id, seconds_since_midnight, now)
    haml :result
  end

end


