require 'csv'
require 'elasticsearch'
require 'sequel'

DB = Sequel.connect('postgres://erik:@localhost/geocode_code_enforcement')
# Execute as shell script if invoked directly.
# Connect to localhost:9200 by default:
ES = Elasticsearch::Client.new

def search_for(address)
  results = ES.search index: 'addresses',
    body: {query: {query_string:
      {default_field: "ADDRESS",
       query: address.gsub("/", " ")}}}
  results["hits"]
end


def geocode(file)
  parcels = DB.from(:parcels)

  output_headers = true

  CSV.foreach(file, headers: true) do |row|
    next if (row["Address"]).nil?
    hits = search_for(row["Address"])
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
end

if caller.empty?
  source_file = ARGV[0]

  if source_file.nil? || source_file.empty?
    puts "Usage: #{__FILE__} <csv_file>"
    exit 1
  end

  geocode(source_file)
end
