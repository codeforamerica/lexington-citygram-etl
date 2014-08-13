echo 'geocode'
ruby geocode_addresses.rb building-permits-2014.csv > building-permits-geocoded-2014.csv

echo 'load into postgres'
psql geocode_code_enforcement -c 'drop table if exists building_permits'
csvsql --db postgresql:///geocode_code_enforcement --insert --table building_permits building-permits-geocoded-2014.csv

echo 'generate geojson'
ruby generate_geojson.rb > building_permits.json
