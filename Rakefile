require 'dotenv';Dotenv.load
require 'json'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'])

class Generate
  def self.building_permits
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

    JSON.generate({'type' => 'FeatureCollection', 'features' => features})
  end


  def self.code_enforcement
    cases = DB.from(:code_enforcement)

    features = cases.order(:StatusDate).reverse().limit(50).all.map do |item|
      title = "Code Enforcement case status updated to '#{item[:Status]}'"
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

    JSON.generate({'type' => 'FeatureCollection', 'features' => features})
  end
end

namespace :generate_geojson do
  task :building_permits do
    p Generate.building_permits
  end

  task :code_enforcement do
    p Generate.code_enforcement
  end
end
