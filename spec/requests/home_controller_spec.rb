# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  describe 'GET /' do
    context 'with empty address' do
      it 'returns response with logo and address form but no forecast' do
        get root_path, params: { address: '' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).not_to include('id="current-and-forecast"')
        assert_not_requested :get, 'https://api.openweathermap.org'
      end
    end

    context 'with a valid address' do
      it 'returns response with forecast' do
        # This is an attenuated payload relative to the full nominatim geocoding
        # response.
        #
        # For more details on OpenStreetMap's Nominatim API see:
        # https://nominatim.org/release-docs/latest/api/Search/
        nominatim_hash = [
          {
            place_id: 4_230_080,
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

        # Mock the Geocoding request.
        # NOTE: Matching the url on a regex to avoid all the query param noise.
        nominatim_req = stub_request(:get, %r{https://nominatim.openstreetmap.org})
                        .to_return(status: 200, body: nominatim_hash.to_json, headers: {})

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
            dt: 1_706_646_015,
            temp: 41.95,
            weather: [{ icon: '04d' }]
          },
          daily: [
            {
              dt: 1_706_634_000,
              temp: { min: 35.13, max: 41.95 },
              weather: [{ icon: '04d' }]
            },
            {
              dt: 1_706_720_400,
              temp: { min: 38.89, max: 47.57 },
              weather: [{ icon: '04d' }]
            },
            {
              dt: 1_706_806_800,
              temp: { min: 39.79, max: 53.83 },
              weather: [{ icon: '01d' }]
            },
            {
              dt: 1_706_893_200,
              temp: { min: 38.1, max: 48.22 },
              weather: [{ icon: '04d' }]
            },
            {
              dt: 1_706_979_600,
              temp: { min: 32.68, max: 44.71 },
              weather: [{ icon: '01d' }]
            },
            {
              dt: 1_707_066_000,
              temp: { min: 32.92, max: 48.29 },
              weather: [{ icon: '01d' }]
            },
            {
              dt: 1_707_152_400,
              temp: { min: 34.2, max: 49.44 },
              weather: [{ icon: '01d' }]
            },
            {
              dt: 1_707_238_800,
              temp: { min: 33.42, max: 46.62 },
              weather: [{ icon: '01d' }]

            }
          ]
        }

        owm_req = stub_request(:get, %r{https://api.openweathermap.org/data/3.0/onecall})
                  .to_return(status: 200, body: owm_hash.to_json, headers: {})

        get root_path, params: { address: '1600 Pennsylvania Avenue NW, Washington, D.C. 20500' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).to include('id="current-and-forecast"')
        assert_requested nominatim_req
        assert_requested owm_req
      end
    end

    context 'with an address that cannot be geocoded' do
      it 'returns flash with error' do
        # Payload is empty array when address cannot be geocoded.
        nominatim_hash = []

        # Mock the Geocoding request.
        # NOTE: Matching the url on a regex to avoid all the query param noise.
        nominatim_req = stub_request(:get, %r{https://nominatim.openstreetmap.org})
                        .to_return(status: 200, body: nominatim_hash.to_json, headers: {})

        get root_path, params: { address: "1234 Derp St\nMinneapolis, MN\n55555" }
        expect(response).to have_http_status(:success) # 200 code, but no data found
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).not_to include('id="current-and-forecast"')
        expect(response.body).to include('Could not find address')
        assert_requested nominatim_req
        assert_not_requested :get, 'https://api.openweathermap.org'
      end
    end

    context 'when Geocoder returns a 503 error' do
      it 'returns logo and address form but no forecast' do
        # Mock Server Error when Geocoding request.
        nominatim_req = stub_request(:get, %r{https://nominatim.openstreetmap.org})
                        .to_return(status: 503, body: '{}', headers: {})

        get root_path, params: { address: "1234 Derp St\nMinneapolis, MN\n55555" }
        expect(response).to have_http_status(:success) # 200 code, but no data found
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).not_to include('id="current-and-forecast"')
        expect(response.body).to include('Address lookup service unavailable.')
        assert_requested nominatim_req
        assert_not_requested :get, 'https://api.openweathermap.org'
      end
    end

    context 'when OpenWeatherMap returns a 5xx error' do
      it 'returns error in the flash and no forecast' do
        # NOTE: Attenuated payload.
        nominatim_hash = [
          {
            place_id: 4_230_080,
            lat: '38.897699700000004',
            lon: '-77.03655315',
            address: {
              house_number: '1600',
              road: 'Pennsylvania Avenue Northwest',
              city: 'Washington',
              state: 'District of Columbia',
              postcode: '20500'
            }
          }
        ]

        nominatim_req = stub_request(:get, %r{https://nominatim.openstreetmap.org})
                        .to_return(status: 200, body: nominatim_hash.to_json, headers: {})

        owm_error_hash = {
          cod: 503,
          message: 'Gone fishing...',
          parameters: []
        }

        owm_req = stub_request(:get, %r{https://api.openweathermap.org/data/3.0/onecall})
                  .to_return(status: owm_error_hash[:cod], body: owm_error_hash.to_json, headers: {})

        get root_path, params: { address: "1234 Derp St\nMinneapolis, MN\n55555" }
        expect(response).to have_http_status(:success) # 200 code, but no data found
        expect(response.body).to include('id="logo"')
        expect(response.body).to include('id="address-form"')
        expect(response.body).not_to include('id="current-and-forecast"')
        expect(response.body).to include('Weather service unavailable.')
        assert_requested nominatim_req
        assert_requested owm_req
      end
    end
  end
end
