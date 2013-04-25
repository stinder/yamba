require_relative 'database'

class DataService

  def get_times_from_db(stop_id, time_in_seconds, today)

    day_of_week = today.strftime('%A').downcase
    today_formatted = today.strftime('%Y%m%d')

    result = StopTime.where(:stop_id => stop_id)
      .joins('LEFT OUTER JOIN trips ON trips.trip_id = stop_times.trip_id LEFT OUTER JOIN calendars ON calendars.service_id = trips.service_id')
      .where('calendars.' + day_of_week +' = 1').where('calendars.start_date <= ? AND calendars.end_date >= ?', today_formatted, today_formatted)
      .where('departure_time > ? ', time_in_seconds)
      .order(:departure_time)
    result[0,10]
  end

end