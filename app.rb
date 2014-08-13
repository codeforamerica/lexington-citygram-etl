require 'dotenv';Dotenv.load
require 'sinatra'
require 'json'
require 'sequel'

get '/code_enforcement' do
  DB = Sequel.connect(ENV['DATABASE_URL'])
  cases = DB.from(:code_enforcement)

  features = cases.order(:StatusDate).reverse().limit(50).all.map do |item|
    title = "Code Enforcement case status updated to '#{item[:Status]}'"
    {
      'id' => item[:CaseNo],
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

  content_type :json
  JSON.pretty_generate({'type' => 'FeatureCollection', 'features' => features})
end
