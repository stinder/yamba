require 'csv'
require_relative 'data'

class DataService

  DATA_FOLDER = 'data'
  TIME_PATTERN = ''

  def initialize (data_file_service=Data.new)
    @data_file_service = data_file_service
  end

  def get_times(stop_id, number_of_buses, time)
    times = @data_file_service.stop_times.select { |row| row['stop_id']==stop_id }.select { |row| time <= DateTime.strptime(row['arrival_time'],'%T')  }.map { |row| ResultItem.new(DateTime.strptime(row['arrival_time'], '%T'))}
    times[0,number_of_buses]
  end

  def load_data

  end

end