require 'csv'

class DataService

  DATA_FOLDER = 'data'
  TIME_PATTERN = ''

  def initialize (csv=CSV)
    @csv = csv
  end

  def get_times(stop_id, number_of_buses)

    time = DateTime.new(2011,2,3,4,5,6,'+7')
    stop_times.select { |row| row["stop_id"]==stop_id }.map { |row| Time.parse(row["arrival_time"]) }




  end

  def load_data



  end

  def stops
    @csv.read('data/stops.txt', :headers=>:first_row)
  end

  def trips
    @csv.read('data/trips.txt', :headers=>:first_row)
  end

  def routes
    @csv.read('data/routes.txt', :headers=>:first_row)
  end

  def stop_times
    @csv.read('data/stop_times.txt', :headers=>:first_row)
  end

end