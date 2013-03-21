require 'csv'

class CsvData
  def stops
    CSV.read('data/stops.txt', :headers=>:first_row)
  end

  def trips
    CSV.read('data/trips.txt', :headers=>:first_row)
  end

  def routes
    CSV.read('data/routes.txt', :headers=>:first_row)
  end

  def stop_times
    CSV.read('data/stop_times.txt', :headers=>:first_row)
  end

end