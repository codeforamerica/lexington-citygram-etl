require 'dotenv';Dotenv.load
require 'json'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'])
cases = DB.from(:building_permits)

features = cases.order(:Date).reverse().limit(50).all.map do |item|
  title = "#{item[:PermitType]} building permit filed at #{item[:Address]} by #{item[:Contractor]}"
  {
    'type' => 'Feature',
    'geometry' => {
      'type' => 'Point',
      'coordinates' => [
        item[:lat].to_f,
        item[:long].to_f
      ]
    },
    'properties' => item.merge('title' => title)
  }
end

p JSON.generate({'type' => 'FeatureCollection', 'features' => features})
