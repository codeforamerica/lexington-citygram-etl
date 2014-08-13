require 'sinatra'
require 'json'

get '/code_enforcement' do
  content_type :json
  JSON.load(File.open('code_enforcement.json'))
end

get '/building_permits' do
  content_type :json
  JSON.load(File.open('building_permits.json'))
end
