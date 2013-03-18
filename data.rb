require 'csv'
class Data

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