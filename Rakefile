require_relative 'data_loader'
require_relative 'database'

desc 'Load additional stop times file'
task :load_stop_times do
  begin
    stop_times_file = ENV['file']
    db_path =  ENV['db']
    data_loader = DataLoader.new
    Database::setup_db(db_path)
    puts "Starting to load additional stop times file: #{stop_times_file}"
    data_loader.load_additional_stop_times_file(stop_times_file)
  rescue
    puts 'Usage: load_stop_times file=<path-to-file> db=<path-to-dbfile>'
  end
end