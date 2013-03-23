require_relative 'result_item'

class DataService

  DATA_FOLDER = 'data'
  TIME_PATTERN = ''

  def get_times_from_db(stop_id, time_in_seconds)
    time_range = time_in_seconds..time_in_seconds + minutes(45)
    StopTime.where(:stop_id => stop_id, :departure_time => time_range).order(:departure_time)
    #create_result_items(stop_times)[0,10]
  end

  private

  def minutes(n)
    60 * n
  end

  def create_result_items(stop_times)
    stop_times.map {|time| ResultItem.new(time) }
  end

end