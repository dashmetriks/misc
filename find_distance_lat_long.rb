require 'json'

def distance_between(lat1, lon1, lat2, lon2)
  rad_per_deg = Math::PI / 180
  rm = 6371000 # Earth radius in meters

  lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg
  lon1_rad, lon2_rad = lon1 * rad_per_deg, lon2 * rad_per_deg

  a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

  rm * c * 0.001
end

results_hash1 = Hash.new

file='latlong.txt'
f = File.open(file, "r")
f.each_line { |line|
 dd =  JSON.parse(line)
 dist = distance_between(53.3381985,-6.2592576, dd['latitude'].to_f, dd['longitude'].to_f)

if dist < 101
 results_hash1[dd['user_id']] = dd["name"]
end
}
f.close

results_hash1.sort.map do |key,value|
 puts "#{key}:#{value}"
end
