require_relative 'result_item'

class DataService

  DATA_FOLDER = 'data'
  TIME_PATTERN = ''

  def get_times_from_db(stop_id, time_in_seconds)
    puts '#######' + time_in_seconds.to_s
    now = DateTime.now
    #time_in_seconds = 30000
    #time_range = time_in_seconds..time_in_seconds + minutes(45)
    stop_times = StopTime.where(:stop_id => stop_id).where('departure_time > ? ', time_in_seconds).order(:departure_time)
    #TODO: move to db query
    stop_times = stop_times.select {|stop_time| stop_time.trip.calendar.sunday == '1'}
    stop_times = stop_times.select {|stop_time| stop_time.trip.calendar.date_matches(now)}
    stop_times[0,10]
  end

  private

  def minutes(n)
    60 * n
  end

  def create_result_items(stop_times)
    stop_times.map {|time| ResultItem.new(time) }
  end

end