require 'date'

class ResultItem

  TIME_PATTERN = '%T'
  attr_accessor :time

  def initialize (stop_time)
    @time = parse_time(stop_time)
  end

  def time_string
    @time.strftime(TIME_PATTERN)
  end

  def parse_time(stop_time)
    Time.new(0) + stop_time.departure_time
  end
end
