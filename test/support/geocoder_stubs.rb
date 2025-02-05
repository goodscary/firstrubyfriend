# test/support/geocoder_stubs.rb
require "geocoder"
Geocoder.configure(lookup: :test, timeout: 1)

# Set a default stub in case an address isn’t explicitly stubbed.
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      "latitude" => 51.0,
      "longitude" => 0.0,
      "address" => "Stubbed Address",
      "state" => "Stubbed State",
      "state_code" => "SS",
      "country" => "Stubbed Country",
      "country_code" => "SC"
    }
  ]
)

# Specific stubs for addresses used in your tests.
Geocoder::Lookup::Test.add_stub("Bournemouth, GB", [
  {
    "latitude" => 50.7200,
    "longitude" => -1.8800,
    "address" => "Bournemouth, GB",
    "state" => "Dorset",
    "state_code" => "DOR",
    "country" => "United Kingdom",
    "country_code" => "GB"
  }
])

Geocoder::Lookup::Test.add_stub("Brighton, GB", [
  {
    "latitude" => 50.8225,
    "longitude" => -0.1372,
    "address" => "Brighton, GB",
    "state" => "East Sussex",
    "state_code" => "ES",
    "country" => "United Kingdom",
    "country_code" => "GB"
  }
])

Geocoder::Lookup::Test.add_stub("Paris, FR", [
  {
    "latitude" => 48.8566,
    "longitude" => 2.3522,
    "address" => "Paris, FR",
    "state" => "Île-de-France",
    "state_code" => "IDF",
    "country" => "France",
    "country_code" => "FR"
  }
])

Geocoder::Lookup::Test.add_stub("New York, US", [
  {
    "latitude" => 40.7128,
    "longitude" => -74.0060,
    "address" => "New York, US",
    "state" => "New York",
    "state_code" => "NY",
    "country" => "United States",
    "country_code" => "US"
  }
])
