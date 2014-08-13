require 'sinatra'
require 'json'
require 'sequel'

# get '/code_enforcement' do
get '/' do
  DB = Sequel.connect('postgres://erik:@localhost/geocode_code_enforcement')
  cases = DB.from(:code_enforcement)

  features = cases.order(:StatusDate).reverse().limit(300).all.map do |item|
    title = "Code Enforcement case status updated to '#{item[:Status]}'"
    {
      'id' => item[:CaseNo],
      'type' => 'Feature',
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          item[:long].to_f,
          item[:lat].to_f
        ]
      },
      'properties' => item.merge('title' => title)
    }
  end
  JSON.pretty_generate({'type' => 'FeatureCollection', 'features' => features})
end
