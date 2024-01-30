require 'rails_helper'

RSpec.describe HomeController, type: :request do
  describe 'GET /' do
    context 'no address' do
      it 'returns response with logo and address form but no forecast' do
        get root_path, params: { address: '' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).to_not include('id="current-and-forecast"')
        assert_not_requested :get, 'https://api.openweathermap.org'
      end
    end

    context 'a valid address' do
      it 'returns response with logo and address form but no forecast' do
        # This is an attenuated payload relative to the full nominatim reverse
        # geocoding response.
        #
        # For more details on OpenStreetMap's Nominatim API see:
        # https://nominatim.org/release-docs/latest/api/Reverse/
        nominatim_hash = [
          {
            place_id: 4230080,
            lat: '38.897699700000004',
            lon: '-77.03655315',
            name: 'White House',
            display_name: 'White House, 1600, Pennsylvania Avenue Northwest, Ward 2, Washington, District of Columbia, 20500, United States',
            address: {
              office: 'White House',
              house_number: '1600',
              road: 'Pennsylvania Avenue Northwest',
              borough: 'Ward 2',
              city: 'Washington',
              state: 'District of Columbia',
              ISO3166_2_lvl4: 'US-DC',
              postcode: '20500',
              country: 'United States',
              country_code: 'us'
            },
            boundingbox: ['38.8974908', '38.8979110', '-77.0368537', '-77.0362519']
          }
        ]

        # Mock the reverse Geocoding request.
        # NOTE: Matching the url on a regex to avoid all the query param noise.
        nominatim_req = stub_request(:get, /https:\/\/nominatim.openstreetmap.org/).
          to_return(status: 200, body: nominatim_hash.to_json, headers: {})

        # The following result hash is an attenuated response payload relative to a
        # "normal" OpenWeatherMap onecall response. Included here are the relevant
        # parts of the JSON for hydrating Weather::Current and Weather::ForecastDay
        # objects.
        #
        # For full response example see:
        # https://openweathermap.org/api/one-call-3#example
        owm_hash = {
          lat: 38.8977,
          lon: -77.0366,
          current: {
            dt: 1706646015,
            temp: 41.95,
            weather: [{ icon: '04d' }]
          },
          daily: [
            {
              dt: 1706634000,
              temp: { min: 35.13, max: 41.95 },
              weather: [{ icon:'04d' }],
            },
            {
              dt: 1706720400,
              temp: { min: 38.89, max: 47.57 },
              weather: [{ icon: '04d' }],
            },
            {
              dt: 1706806800,
              temp: { min: 39.79, max: 53.83 },
              weather: [{ icon: '01d' }],
            },
            {
              dt: 1706893200,
              temp: { min: 38.1, max: 48.22 },
              weather: [{ icon: '04d' }],
            },
            {
              dt: 1706979600,
              temp: { min: 32.68, max: 44.71 },
              weather: [{ icon: '01d' }],
            },
            {
              dt: 1707066000,
              temp: { min: 32.92, max: 48.29 },
              weather: [{ icon: '01d' }],
            },
            {
              dt: 1707152400,
              temp: { min: 34.2, max: 49.44 },
              weather: [{ icon: '01d' }],
            },
            {
              dt: 1707238800,
              temp: { min: 33.42, max: 46.62 },
              weather: [{ icon: '01d' }],

            }
          ]
        }

        owm_req = stub_request(:get, /https:\/\/api.openweathermap.org\/data\/3.0\/onecall/).
          to_return(status: 200, body: owm_hash.to_json, headers: {})

        get root_path, params: { address: '1600 Pennsylvania Avenue NW, Washington, D.C. 20500' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).to include('id="current-and-forecast"')
        assert_requested nominatim_req
        assert_requested owm_req
      end
    end

    context 'an address that cannot be reverse geocoded' do
      it 'returns response with logo and address form but no forecast' do
        # Payload is empty array when address cannot be reverse geocoded.
        nominatim_hash = []

        # Mock the reverse Geocoding request.
        # NOTE: Matching the url on a regex to avoid all the query param noise.
        nominatim_req = stub_request(:get, /https:\/\/nominatim.openstreetmap.org/).
          to_return(status: 200, body: nominatim_hash.to_json, headers: {})

        get root_path, params: { address: "1234 Derp St\nMinneapolis, MN\n55555" }
        expect(response).to have_http_status(:success) # 200 code, but no data found
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).to_not include('id="current-and-forecast"')
        expect(response.body).to include('Could not find address')
        assert_requested nominatim_req
        assert_not_requested :get, 'https://api.openweathermap.org'
      end
    end
  end
end
