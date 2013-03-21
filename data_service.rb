require 'csv'
require_relative 'csv_data'

class DataService

  DATA_FOLDER = 'data'
  TIME_PATTERN = ''

  def initialize (data=CsvData.new)
    @data = data
    @stop_times = @data.stop_times
  end

  def get_times(stop_id, number_of_buses, time)
    times = @stop_times.select { |row| row['stop_id']==stop_id }.select { |row| time <= DateTime.strptime(row['arrival_time'],'%T')  }.map { |row| ResultItem.new(DateTime.strptime(row['arrival_time'], '%T'))}
    times[0,number_of_buses]
  end

end