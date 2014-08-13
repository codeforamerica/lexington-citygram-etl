function etl_building_permits {
  echo 'geocode building permits'
  ruby geocode_addresses.rb building-permits-2014.csv > building-permits-geocoded-2014.csv

  echo 'load into postgres'
  psql geocode_code_enforcement -c 'drop table if exists building_permits'
  csvsql --db postgresql:///geocode_code_enforcement --insert --table building_permits building-permits-geocoded-2014.csv

  echo 'generate geojson'
  rake generate_geojson:building_permits > building_permits.json
}

function etl_code_enforcement {
  echo 'geocode code enforcement'
  ruby geocode_addresses.rb code-enforcement-2014.csv > code-enforcement-geocoded-2014.csv

  echo 'load into postgres'
  psql geocode_code_enforcement -c 'drop table if exists code_enforcement'
  csvsql --db postgresql:///geocode_code_enforcement --insert --table code_enforcement code-enforcement-geocoded-2014.csv

  echo 'generate geojson'
  rake generate_geojson:code_enforcement > code_enforcement.json
}

etl_building_permits
etl_code_enforcement
