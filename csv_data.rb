require 'csv'

class CsvData

  def initialize (folder='gtfs')
    @folder = folder
  end

  def stops
    CSV.read(@folder +'/stops.txt', :headers=>:first_row)
  end

  def trips
    CSV.read(@folder +'/trips.txt', :headers=>:first_row)
  end

  def routes
    CSV.read(@folder +'/routes.txt', :headers=>:first_row)
  end

  def calendars
    CSV.read(@folder + '/calendar.txt', :headers=>:first_row)
  end

  def stop_times_fragment(suffix)
    CSV.read(@folder + '/times-' + suffix, :headers=>:first_row, :row_sep => :auto)
  end

  def stop_times
    CSV.read(@folder + '/stop_times.txt', :headers=>:first_row)
  end

  def stop_times_file(filename)
    CSV.read(@folder + '/' + filename, :headers=>:first_row)
  end
end