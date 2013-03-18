require 'date'

class ResultItem

  TIME_PATTERN = '%T'
  attr_accessor :time

  def initialize (time)
    @time = time
  end

  def time_string
    @time.strftime(TIME_PATTERN)
  end
end
