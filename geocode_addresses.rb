require 'csv'
require 'elasticsearch'
require 'sequel'

# Connect to localhost:9200 by default:
es = Elasticsearch::Client.new

DB = Sequel.connect('postgres://erik:@localhost/geocode_code_enforcement')
parcels = DB.from(:parcels)

def search_for(es, address)

  results = es.search index: 'addresses',
    body: {query: {query_string:
      {default_field: "ADDRESS",
       query: address.gsub("/", " ")}}}
  results["hits"]
end

output_headers = true

CSV.foreach('/Users/erik/code/citygram_data/code-enforcement-2014.csv', headers: true) do |row|
  hits = search_for(es, row["Address"])
  match = hits['hits'].first['_source']
  parcel_id = match["PVANUM"]
  parcel = parcels.where('"PVANUM" = ?', parcel_id.to_i).first

  row[:parcel_id] = parcel_id
  row[:lat] = parcel[:X]
  row[:long] = parcel[:Y]

  if output_headers
    CSV { |csv_out| csv_out << row.headers }
    output_headers = false
  end

  CSV { |csv_out| csv_out << row }
end
