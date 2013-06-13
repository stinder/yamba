require 'net/http'
require 'pp'

class LookupService

  def lookup_locations(postcode, radius=1.2)
    postcode_data = get_lat_long_for(postcode)
    get_bus_stops_within_range(postcode_data[:lat].to_f, postcode_data[:lng].to_f, radius)
  end

  def get_lat_long_for(postcode)
    http = get_http()
    path = "/postcode/#{sanitise_input(postcode)}.json"
    request = Net::HTTP::Get.new path
    request_body = http.request(request).body
    postcode_data = JSON.parse(request_body, {:symbolize_names => true})
    postcode_data[:geo]
  end

  def get_bus_stops_within_range(lat, lon, radius_in_km)
    half_radius = radius_in_km.to_f * 0.009 / 2
    BusStop
    .where('stop_lat >= ? AND stop_lat <= ?', lat - half_radius, lat + half_radius)
    .where('stop_lon >= ? AND stop_lon <= ?', lon - half_radius, lon + half_radius)
  end

  def get_http
    http = Net::HTTP.new 'uk-postcodes.com', 80
    http.read_timeout = 10
    http
  end

  def sanitise_input(postcode)
    postcode.gsub(/\s+/, '').upcase
  end

end
