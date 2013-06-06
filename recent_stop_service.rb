require_relative 'database'

class RecentStopService

  def get_recent_stops(request, bust_stop = BusStop)
    stop_ids = get_stop_ids_from_cookie(request)
    return [] if stop_ids.empty?
    where_clause = stop_ids.map{|stop_id| "stop_id='#{stop_id}'"}.join(' OR ')
    bust_stop.where(where_clause)
  end

  def get_stop_ids_from_cookie(request)
    cookie_string = request.cookies['yamba']
    cookie_string ? cookie_string.split(';') : []
  end

  def create_cookie_without_bus_stop(request, stop_id)
    current_list = get_stop_ids_from_cookie(request)
    new_list = get_id_string_without(current_list, stop_id)
    create_cookie_with_list(new_list)
  end


  def create_cookie_string_from_list(new_list)
    new_list.join(';')
  end

  def get_id_string_without(list, id)
    list.select{|item| item != id}
  end

  def create_cookie_with_additional_bus_stop(request, stop_id)
    stop_ids = get_stop_ids_from_cookie(request)
    stop_ids << stop_id unless stop_ids.include? stop_id
    create_cookie_with_list(stop_ids)
  end

  def create_cookie_with_list(stop_ids)
    {:value => create_cookie_string_from_list(stop_ids), :expires => Time.now + 3000000, :path => '/'}
  end
end